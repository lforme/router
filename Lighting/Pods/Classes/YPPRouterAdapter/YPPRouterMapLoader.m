//
//  YPPRouterMapLoader.m
//  Lighting
//
//  Created by lujinhui on 2020/3/6.
//

#import "YPPRouterMapLoader.h"

#import <objc/message.h>

#import "YPPRouterConst.h"
#import "YPPRouter.h"
#import "YPPRouterURLParser.h"

#ifdef DEBUG
#define YPPRouterCheckScheme
#endif

@interface YPPRouterMapLoader ()

@property (nonatomic, copy) NSDictionary *schemeMaps;

@property (nonatomic, strong) NSMutableDictionary *oldSchemeMaps;

@end

@implementation YPPRouterMapLoader

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[YPPRouterMapLoader sharedLoader] loadMaps];
    });
}

+ (instancetype)sharedLoader {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)loadMaps {
    
    [self loadNewMaps];
    [self loadOldMaps];
}

#pragma mark - 新路由映射

// 加载新map
- (void)loadNewMaps {
    
    Class ymMapClass = NSClassFromString(@"YPPRouterMap");
    if (!ymMapClass) {
        YPPLogAction(@"- Warning: Class 'YPPRouterMap' Not Found!");
        return;
    }
    
    SEL schemeMapsSelector = NSSelectorFromString(@"schemeMap");
    if (!schemeMapsSelector || ![ymMapClass respondsToSelector:schemeMapsSelector]) {
        YPPLogAction(@"- Warning: YPPRouterMap does not responds to selector: + schemeMap");
        return;
    }
    
    NSDictionary * (*ymMapAction)(id, SEL) = (id (*)(id, SEL))objc_msgSend;
    NSDictionary *schemeMaps = ymMapAction(ymMapClass, schemeMapsSelector);
    
    if ([schemeMaps isKindOfClass:[NSDictionary class]]) {
        self.schemeMaps = schemeMaps;
    }
    
#ifdef YPPRouterCheckScheme
    [self checkSchemeMapsRespond];
#endif
}

#pragma mark - 旧路由映射

- (NSMutableDictionary *)oldSchemeMaps {
    if (!_oldSchemeMaps) {
        _oldSchemeMaps = [NSMutableDictionary dictionary];
    }
    return _oldSchemeMaps;
}

// 加载旧map
- (void)loadOldMaps {
    
    NSString *bundlePath = [NSBundle mainBundle].bundlePath;
    NSError *error;
    NSArray<NSString *> *files =  [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundlePath error:&error];
    if (error) {
        NSAssert(NO, @"获取文件失败");
        return;
    }
    [files enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj hasPrefix:SCHEME_PLIST_NAME] && [obj hasSuffix:@".plist"]) {
            NSString *absolutPath = [bundlePath stringByAppendingPathComponent:obj];
            if (![[NSFileManager defaultManager] fileExistsAtPath:absolutPath]) {
                return;
            }
            [self loadPluginWithArray:[NSArray arrayWithContentsOfFile:absolutPath]];
        }
        
        if ([obj hasPrefix:SCHEME_PAGE_NAME] && [obj hasSuffix:@".plist"]) {
            NSString *absolutPath = [bundlePath stringByAppendingPathComponent:obj];
            if (![[NSFileManager defaultManager] fileExistsAtPath:absolutPath]) {
                return;
            }
            [self loadPageWithArray:[NSArray arrayWithContentsOfFile:absolutPath]];
        }
    }];
}

- (void)loadPluginWithArray:(NSArray* )pluginArray {
    for (NSDictionary* plugin in pluginArray) {
        NSString* pluginName = plugin[ROUTER_PLUGINNAME_KEY];
        NSString* className = plugin[ROUTER_CLASSNAME_KEY];
        NSNumber* isStaticNumValue = plugin[ROUTER_ISCLASSMETHOD_KEY];
        BOOL isStaticMethod = [isStaticNumValue boolValue];
        NSString* funcName = plugin[ROUTER_CALLFUNCNAME_KEY];
        
#ifdef YPPRouterCheckScheme
        if (![self checkOldSchemeWithClassName:className selectorName:funcName isStaticMethod:isStaticMethod]) continue;
#endif
        
        Class pluginClass = NSClassFromString(className);
        
        id obj = isStaticMethod ? pluginClass : [[pluginClass alloc] init];
        if (!obj) {
            NSAssert(NO, @"无法响应的plugin");
            continue;
        }
        
        SEL selector = NSSelectorFromString(funcName);
        if (![obj respondsToSelector:selector]) {
            NSAssert(NO, @"无法响应的plugin");
            continue;
        }
        
        void(*objcMsgSend)(id, SEL, NSDictionary*) = (void*)objc_msgSend;
        
        NSString *pathId = [NSString stringWithFormat:@"/%@/%@", SCHEME_FUNC_PLUGIN, pluginName];
        
        [self.oldSchemeMaps setObject:^id(NSDictionary *params) {
            objcMsgSend(obj, selector, params);
            return nil;
        } forKey:pathId];
    }
}

- (void)loadPageWithArray:(NSArray *)pageInArray {
    for (NSDictionary* page in pageInArray) {
        NSString *pageName = page[ROUTER_PAGENAME_KEY];
        NSString *className = page[ROUTER_CLASSNAME_KEY];
        NSString *businessName = page[ROUTER_PAGE_BUSINESSNAME_KEY];
        NSNumber *isStaticNumValue = page[ROUTER_ISCLASSMETHOD_KEY];
        BOOL isStaticMethod = [isStaticNumValue boolValue];
        NSString* funcName = page[ROUTER_CALLFUNCNAME_KEY];
        
#ifdef YPPRouterCheckScheme
        if (![self checkOldSchemeWithClassName:className selectorName:funcName isStaticMethod:isStaticMethod]) continue;
#endif
        
        Class pluginClass = NSClassFromString(className);
        
        id obj = isStaticMethod ? pluginClass : [[pluginClass alloc] init];
        if (!obj) {
            NSAssert(NO, @"无法响应的npage");
            continue;
        }
        
        SEL selector = NSSelectorFromString(funcName);
        if (![obj respondsToSelector:selector]) {
            NSAssert(NO, @"无法响应的npage");
            continue;
        }
        
        void(*objcMsgSend)(id, SEL, NSDictionary*) = (void*)objc_msgSend;

        NSString *pathId = [NSString stringWithFormat:@"/%@/%@/%@", SCHEME_FUNC_NATIVEPAGE, businessName, pageName];
        
        [self.oldSchemeMaps setObject:^id(NSDictionary *params) {
            objcMsgSend(obj, selector, params);
            return nil;
        } forKey:pathId];
    }
}

- (void)loadQuickPageWithArray:(NSArray *)pageInArray {
    for (NSDictionary* page in pageInArray) {
        NSString *pageName = page[ROUTER_PAGENAME_KEY];
        NSString *className = page[ROUTER_CLASSNAME_KEY];
        NSString *businessName = page[ROUTER_PAGE_BUSINESSNAME_KEY];
        NSString* funcName = ROUTER_QUICKPAGEFUNCNAMESTR;
        
#ifdef YPPRouterCheckScheme
        Class pluginClass = NSClassFromString(className);
        id controller = [[pluginClass alloc] init];
        if (!controller) {
            NSAssert(NO, @"无法响应的npage");
            continue;
        }

        SEL selector = NSSelectorFromString(funcName);
        if (![controller isKindOfClass:[UIViewController class]] && ![controller respondsToSelector:selector]) {
            NSAssert(NO, @"无法响应的npage");
            continue;
        }
#endif
        
        NSString *pathId = [NSString stringWithFormat:@"/%@/%@/%@", SCHEME_FUNC_NATIVEPAGE, businessName, pageName];
        
        [self.oldSchemeMaps setObject:^id(NSDictionary *params) {
            
            BOOL(*objcMsgSend)(id, SEL, NSDictionary*) = (void*)objc_msgSend;

            Class pluginClass = NSClassFromString(className);
            
            id controller = [[pluginClass alloc] init];
            if (!controller) {
                return nil;
            }
            
            SEL selector = NSSelectorFromString(funcName);
            if ([controller isKindOfClass:[UIViewController class]] && ![controller respondsToSelector:selector]) {
                UINavigationController *navigation = [[YPPRouter shared].navigationGetter getCurrentNavigation];
                if (!navigation) {
                    return nil;
                }
                
                NSMutableDictionary* vcParams = [NSMutableDictionary dictionaryWithDictionary:params];
                [vcParams removeObjectForKey:@"block"];
                [vcParams removeObjectForKey:@"route"];
                [controller setValuesForKeysWithDictionary:vcParams];
                
                ((UIViewController*)controller).hidesBottomBarWhenPushed = YES;
                [navigation pushViewController:controller animated:YES];
            }else {
                if (![controller respondsToSelector:selector]) {
                    return nil;
                }

                BOOL isValid = objcMsgSend(controller, selector, params);
                if (!isValid) {
                    return nil;
                }
            
                if ([controller isKindOfClass:[UIViewController class]]) {
                    UINavigationController *navigation = [[YPPRouter shared].navigationGetter getCurrentNavigation];
                    if (!navigation) {
                        return nil;
                    }

                    ((UIViewController*)controller).hidesBottomBarWhenPushed = YES;
                    [[[YPPRouter shared].navigationGetter getCurrentNavigation] pushViewController:controller animated:YES];
                }
            }
            return nil;
        } forKey:pathId];
    }
}

- (void)addPlugin:(NSString *)pluginName toBlock:(void(^)(NSDictionary *params))block {
    if ([pluginName isKindOfClass:[NSString class]] && pluginName.length > 0) {
        [self.oldSchemeMaps setObject:block forKey:[@"/" stringByAppendingPathComponent:pluginName]];
    }
}

#pragma mark - 检测路由方法实现

/// 检测旧路由方法是否实现
- (BOOL)checkOldSchemeWithClassName:(NSString *)className selectorName:(NSString *)selectorName isStaticMethod:(BOOL)isStaticMethod {
    
    Class pluginClass = NSClassFromString(className);
    
    id obj = isStaticMethod ? pluginClass : [[pluginClass alloc] init];
    if (!obj) {
        NSString *info = [NSString stringWithFormat:@"无法响应的class: %@", className];
        NSAssert(NO, info);
        return NO;
    }
    
    SEL selector = NSSelectorFromString(selectorName);
    if (![obj respondsToSelector:selector]) {
        NSString *info = [NSString stringWithFormat:@"无法响应的action: %@", selectorName];
        NSAssert(NO, info);
        return NO;
    }
    return YES;
}

// 检测新路由方法是否实现
- (void)checkSchemeMapsRespond {
    // 检查action是否实现
    [self.schemeMaps enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        SEL selector = NSSelectorFromString(obj);
        if (!(selector && [[YPPRouter shared] respondsToSelector:selector])) {
            NSString *info = [NSString stringWithFormat:@"action: %@ 未实现, path_id 为 %@", obj, key];
            NSAssert(NO, info);
        }
    }];
}


@end
