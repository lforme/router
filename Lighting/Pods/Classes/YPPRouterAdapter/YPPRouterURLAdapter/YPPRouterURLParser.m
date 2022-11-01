//
//  YPPRouterURLParser.m
//  YPP-router
//
//  Created by lujinhui on 2020/1/6.
//

#import "YPPRouterURLParser.h"

#import <objc/message.h>

#import "YPPParamsBuilder.h"

#import "YPPRouterMapLoader.h"

#import "YPPRouter.h"

#import "YPPRouterConst.h"

#import "MJExtension.h"

typedef NS_ENUM(NSUInteger, YMUrlType) {
    YMUrlTypeScheme,
    YMUrlTypeUniversalLink,
};

@interface YPPRouterURLParser ()

@end

@implementation YPPRouterURLParser

+ (instancetype)sharedInstance {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)parseURL:(NSURL *)url withExtensionDic:(NSDictionary *)extensionDic {
    
    YPPLogAction(@"- parse URL: %@", url);
    
    if (url.absoluteString.length < 1) {
        return;
    }
    
    // 判断URL是否符合Scheme或域名规则
    if ([url.scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame
        || [url.scheme compare:@"http" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        
        // 判断是否是universal link
        if ([self isSupportHost:url.host]) {
            // 解析url
            [self parseUrl:url withType:YMUrlTypeUniversalLink withExtensionDic:extensionDic];
        }
        
    } else {
        
        //判断该Scheme是否支持解析
        if ([self isSupportScheme:url.scheme]) {
            // 解析url
            [self parseUrl:url withType:YMUrlTypeScheme withExtensionDic:extensionDic];
        }
    }
}

- (void)parseUrl:(NSURL *)url withType:(YMUrlType)type withExtensionDic:(NSDictionary *)extensionDic {
    
    switch (type) {
            
        case YMUrlTypeScheme: {
            
            NSString *urlHost = url.host;
            NSString *urlPath = url.path;
            NSString *pathId = [NSString stringWithFormat:@"/%@%@",urlHost,urlPath];
            
            [self parsePathId:pathId withURL:url withExtensionDic:extensionDic];
            
            break;
        }
        case YMUrlTypeUniversalLink: {
            
            NSString *pathId = url.path;
            
            [self parsePathId:pathId withURL:url withExtensionDic:extensionDic];
            
            break;
        }
        default:
            break;
    }
}

- (void)parsePathId:(NSString *)pathId withURL:(NSURL *)url withExtensionDic:(NSDictionary *)extensionDic {
    
    NSString *action = [YPPRouterMapLoader sharedLoader].schemeMaps[pathId];
    
    if (action && action.length > 0) {
        [self performAction:action withParams:[self paramsFromUrl:url.absoluteString withExtensionDic:extensionDic]];
    } else {
        id (^oldRouteBlock)(NSDictionary *) = [YPPRouterMapLoader sharedLoader].oldSchemeMaps[pathId];
        if (oldRouteBlock) {
            oldRouteBlock([self paramsFromUrl:url.absoluteString withExtensionDic:extensionDic]);
        } else {
            // 暂时兼容page方式
            [self parsePageSchemeWithPathId:pathId withURL:url withExtensionDic:extensionDic];
        }
    }
}

// 暂时兼容page方式，有缺陷！！！尽快更新使用新规则！！
- (void)parsePageSchemeWithPathId:(NSString *)pathId withURL:(NSURL *)url withExtensionDic:(NSDictionary *)extensionParams {
    
    NSMutableArray *pathComponents = [NSMutableArray array];
    for (NSString *pathComponent in pathId.pathComponents) {
        if ([pathComponent isEqualToString:@"/"]) {
            continue;
        }
        [pathComponents addObject:[pathComponent stringByRemovingPercentEncoding]];
    }
    
    if ([pathComponents[0] isEqualToString:@"page"]) {
        
        UINavigationController* navigationController = [[YPPRouter shared].navigationGetter getCurrentNavigation];
        
        if (!navigationController) {
            YPPLogAction(@"- Warning: pathId: '%@', [[YPPRouter shared].navigationGetter getCurrentNavigation], NavigationController Not Found!", pathId);
            return;
        }
        
        if (pathComponents.count < 2) {
            YPPLogAction(@"- Warning: '%@' unrecognized path_id to parse", pathId);
            return;
        }
        
        NSString *controllerClassName = pathComponents[1];
        Class controllerClass = NSClassFromString(controllerClassName);
        if (!controllerClass) {
            YPPLogAction(@"- Warning: Class '%@' Not Found!", controllerClassName);
            return;
        }
        
        id controller = [[controllerClass alloc] init];
        if (!controller || ![controller isKindOfClass:[UIViewController class]]) {
            YPPLogAction(@"- Warning: Class '%@' is not kind of Class UIViewController!", controllerClassName);
            return;
        }
        
        NSDictionary *params = [self paramsFromUrl:url.absoluteString withExtensionDic:extensionParams];
        NSMutableDictionary *vcParams = [NSMutableDictionary dictionaryWithDictionary:params];
        if (extensionParams.count > 0) {
            [vcParams addEntriesFromDictionary:extensionParams];
        }
        
        // 临时使用，有缺陷！！！尽快更新使用新规则！！
        [controller setValuesForKeysWithDictionary:vcParams];
        
        NSString *pageTransType = SCHEME_EXTRA_PAGE_PUSH;
        BOOL isHasExtraComponents = pathComponents.count > 2;
        
        if (isHasExtraComponents) {
            pageTransType = pathComponents[2];
        }
        
        ((UIViewController *)controller).hidesBottomBarWhenPushed = YES;
        if ([pageTransType isEqualToString:SCHEME_EXTRA_PAGE_PUSH]) {
            [navigationController pushViewController:controller animated:YES];
        }else if ([pageTransType isEqualToString:SCHEME_EXTRA_PAGE_PRESENT]) {
            [navigationController presentViewController:controller animated:YES completion:nil];
        }
    } else {
        YPPLogAction(@"- Warning: '%@' unrecognized path_id to parse", pathId);
    }
}

// 解析参数
- (NSDictionary *)paramsFromUrl:(NSString *)urlStr withExtensionDic:(NSDictionary *)extensionDic {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    // 判断'url'是否是最后一个参数，对url参数特殊处理，url参数不参与decode
    NSRange urlRange = [urlStr rangeOfString:@"url="];
    if (urlRange.location != NSNotFound && urlStr.length > urlRange.location + urlRange.length) {
        NSString *urlParamString = [urlStr substringFromIndex:urlRange.location + urlRange.length];
        
        NSString *allParamsString = [urlStr substringToIndex:urlRange.location];
        
        [params addEntriesFromDictionary:[self paramsFromCommonUrl:allParamsString]];
        
        if ([urlParamString containsString:@"?"]) {
            [params setObject:urlParamString forKey:@"url"];
        } else {
            // 如果后面没有参数
            // 检查urlParamString里是否有&，分割&，并检查是否有length大于0的参数
            NSArray <NSString *>*paramStringArr = [urlParamString componentsSeparatedByString:@"&"];
            if (paramStringArr.count <= 1) {
                // 是最后一个参数
                [params setObject:urlParamString forKey:@"url"];
            } else {
                [params setObject:paramStringArr[0] forKey:@"url"];
                for (NSString *paramString in paramStringArr) {
                    NSArray *paramArr = [paramString componentsSeparatedByString:@"="];
                    if (paramArr.count > 1) {
                        NSString *key = [[paramArr objectAtIndex:0] stringByRemovingPercentEncoding];
                        NSString *value = [[paramString substringFromIndex:key.length+1] stringByRemovingPercentEncoding];
                        params[key] = value;
                    }
                }
            }
        }
    } else {
        
        [params addEntriesFromDictionary:[self paramsFromCommonUrl:urlStr]];
    }
    
    if ([extensionDic isKindOfClass:[NSDictionary class]] && extensionDic.count > 0) {
        [params addEntriesFromDictionary:extensionDic];
    }
    
    return [params copy];
}

// 对标准url解析参数
- (NSMutableDictionary *)paramsFromCommonUrl:(NSString *)urlStr {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSRange firstRange = [urlStr rangeOfString:@"?"];
    if (firstRange.location != NSNotFound && urlStr.length > firstRange.location + firstRange.length) {
        NSString *paramsString = [urlStr substringFromIndex:firstRange.location + firstRange.length];
        NSArray *paramStringArr = [paramsString componentsSeparatedByString:@"&"];
        for (NSString *paramString in paramStringArr) {
            NSArray *paramArr = [paramString componentsSeparatedByString:@"="];
            if (paramArr.count > 1) {
                NSString *key = [[paramArr objectAtIndex:0] stringByRemovingPercentEncoding];
                NSString *value = [[paramString substringFromIndex:key.length+1] stringByRemovingPercentEncoding];
                params[key] = value;
            }
        }
    }
    return params;
}

#pragma mark - support links

// 是否支持该Scheme
- (BOOL)isSupportScheme:(NSString *)scheme {
    
    // TODO:支持列表待扩展，用于区分测试和线上环境
    
    return YES;
}

// 是否支持该universal link的host
- (BOOL)isSupportHost:(NSString *)host {
    
    // TODO:支持列表待扩展，用于区分测试和线上环境
//    NSArray *supportUlLinks = @[@"ulink.hibixin.com"];
//
//    __block BOOL find = NO;
//    [supportUlLinks enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj isEqualToString:host]) {
//            find = YES;
//            *stop = YES;
//        }
//    }];
    
    return YES;
}

#pragma mark - invoke

- (void)performAction:(NSString *)action withParams:(NSDictionary *)params {
    
    void (^performAction)(void) = ^(){
        
        SEL selector = NSSelectorFromString(action);
        
        if (selector && [[YPPRouter shared] respondsToSelector:selector]) {
            
            [self safePerformAction:selector target:[YPPRouter shared] params:^(YPPParamsBuilder *builder) {
                // 将params映射到builder中
                if ([builder respondsToSelector:@selector(ym_replacedKeyFromPropertyName)]) {
                    NSDictionary *replacedDic = [builder ym_replacedKeyFromPropertyName];
                    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        id replacedKey = replacedDic[key];
                        [builder setValue:obj forKey:replacedKey ?: key];
                    }];
                } else {
                    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        [builder setValue:obj forKey:key];
                    }];
                }
            }];
        } else {
            YPPLogAction(@"'%@', action not respond.", action);
        }
    };
    
    if ([params[@"needLogin"] boolValue] && [[YPPRouter shared].delegate respondsToSelector:@selector(routerNeedLogin:)]) {
        [[YPPRouter shared].delegate routerNeedLogin:^(BOOL isLogin) {
            if (isLogin) {
                performAction();
            }
        }];
    } else {
        performAction();
    }
}

- (id)oldPerformAction:(NSString *)action target:(NSString *)target withParams:(NSDictionary *)params {

    SEL oldActionSEL = NSSelectorFromString(action);
    Class oldTargetClass = NSClassFromString(target);
    
    if (!(oldActionSEL && oldTargetClass)) {
        YPPLogAction(@"- Warning: target: %@, action: %@, not respond", target, action);
        return nil;
    }
    
    void(*objcMsgSend)(id, SEL, NSDictionary*) = (void*)objc_msgSend;
    if ([oldTargetClass respondsToSelector:oldActionSEL]) {
        objcMsgSend(oldTargetClass, oldActionSEL, params);
    } else if ([oldTargetClass instancesRespondToSelector:oldActionSEL]) {
        id oldTargetObj = [[oldTargetClass alloc] init];
        objcMsgSend(oldTargetObj, oldActionSEL, params);
    } else {
        YPPLogAction(@"- Warning: target: %@, action: %@, not respond", target, action);
    }
    return nil;
}

- (id)safePerformAction:(SEL)action target:(NSObject *)target params:(id)params {
    
    NSMethodSignature* methodSig = [target methodSignatureForSelector:action];
    if(methodSig == nil) {
        return nil;
    }
    const char* retType = [methodSig methodReturnType];
    
    if (strcmp(retType, @encode(void)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        return nil;
    }
    
    if (strcmp(retType, @encode(NSInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    
    if (strcmp(retType, @encode(BOOL)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        BOOL result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    
    if (strcmp(retType, @encode(CGFloat)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        CGFloat result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    
    if (strcmp(retType, @encode(NSUInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSUInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
}

@end
