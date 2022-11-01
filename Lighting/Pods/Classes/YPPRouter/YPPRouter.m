//
//  YPPRouter.m
//  YPP-router
//
//  Created by lujinhui on 2020/1/4.
//  Copyright © 2020 lujinhui. All rights reserved.
//

#import "YPPRouter.h"

#import "YPPParamsBuilder.h"
#import "YPPRouterURLAdapter.h"
#import "YPPRouterMapLoader.h"
#import <objc/runtime.h>

@implementation YPPRouter

#pragma mark - Public

+ (instancetype)shared {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (BOOL)processUrl:(NSString *)urlStr {
    return [self processUrl:urlStr needConvertScheme:YES];
}

- (BOOL)processUrl:(NSString *)urlStr needConvertScheme:(BOOL)needConvertScheme {
    return [self processUrl:urlStr needConvertScheme:needConvertScheme extensionDic:nil];
}

- (BOOL)processUrl:(NSString *)urlString needConvertScheme:(BOOL)needConvertScheme extensionDic:(NSDictionary *)extensionDic {
    
    if (![urlString isKindOfClass:[NSString class]]) {
        return NO;
    }
    
    // 校验urlString，生成URL
    NSURL *url = [self getVerifyURLWithUrlStr:urlString];
    if (!url) {
        return NO;
    }
    
    // 建议全部使用正确格式调用，暂时这样支持下webpage/push的简单调用。
    if ([url.scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame
        || [url.scheme compare:@"http" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        
        // 判断是否是universal link
        if (![self isUlHost:url.host]) {
            // 通过webpage/push打开网页
            NSString *urlStr = [NSString stringWithFormat:@"ypp-router://webpage/push?url=%@", url.absoluteString];
            url = [NSURL URLWithString:urlStr];
        }
        
        [[YPPRouterURLAdapter sharedAdapter] handleURL:url withExtensionDic:extensionDic];
        return YES;
    }
    
    // extraSchemeArray 以外的 Scheme 不做处理
    if ([self.extraSchemeArray containsObject:url.scheme]) {
        
        if (needConvertScheme) {
            // 直接解析url
            [[YPPRouterURLAdapter sharedAdapter] handleURL:url withExtensionDic:extensionDic];
            
            return YES;
            
        } else { // 不直接解析url
            
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
                return YES;
            } else {
                return NO;
            }
        }
    } else {
        return NO;
    }
}

- (NSURL *)getVerifyURLWithUrlStr:(NSString *)urlStr {
    
    NSString *rawUrlStr = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (rawUrlStr.length > 0) {
        NSURL *url = [NSURL URLWithString:rawUrlStr];
        if (!url) {
            NSString *decodeUrlStr = [rawUrlStr stringByRemovingPercentEncoding];
            if (decodeUrlStr) {
                url = [NSURL URLWithString:[decodeUrlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            } else {
                url = [NSURL URLWithString:[rawUrlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            }
        }
        return url;
    }
    return nil;
}

#pragma mark - Private

// 是否是支持的universal links中的host
- (BOOL)isUlHost:(NSString *)host {
    
    NSArray *ulLinks = @[@"ulink.hibixin.com"];
    
    __block BOOL find = NO;
    [ulLinks enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:host]) {
            find = YES;
            *stop = YES;
        }
    }];
    
    return find;
}

@end

@implementation YPPRouter(Old)

#pragma mark - 兼容旧实现

/// 仅用于兼容老代码
- (NSDictionary *)parseParamsInRoute:(NSString *)route {
    
    NSArray* nestingUrlArray = [route componentsSeparatedByString:@"url="];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSURL *url = [NSURL URLWithString:[nestingUrlArray[0] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    if (url) {
        NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:YES];
        
        [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.value) {
                [params setObject:obj.value forKey:obj.name];
            }
        }];
    }
    
    NSMutableDictionary* vcParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [vcParams removeObjectForKey:@"route"];
    if (nestingUrlArray.count==2) {
        vcParams[@"url"] = nestingUrlArray[1];
    }
    
    return vcParams;
}

- (BOOL)canProcessUrl:(NSString *)url {
    return YES;
}

- (BOOL)processUrl:(NSString *)urlStr extensionDic:(NSDictionary *)extensionParams {
    
    return [self processUrl:urlStr needConvertScheme:YES extensionDic:extensionParams];
}

- (void)addPlugin:(NSString *)pluginName toBlock:(void(^)(NSDictionary *params))block {
    [[YPPRouterMapLoader sharedLoader] addPlugin:pluginName toBlock:block];
}

- (void)addQuickPageSchemeArray:(NSArray *)quickPageSchemeArray {
    if (quickPageSchemeArray) {
        [[YPPRouterMapLoader sharedLoader] loadQuickPageWithArray:quickPageSchemeArray];
    }
}

@end
