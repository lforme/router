//
//  YPPRouterURLAdapter.m
//  YPP-router
//
//  Created by lujinhui on 2020/1/4.
//

#import "YPPRouterURLAdapter.h"

#import "YPPRouterHookService.h"
#import "YPPRouterURLParser.h"
#import "YPPRouter.h"

@interface YPPRouterURLAdapter ()

@property (nonatomic, strong) NSMutableArray *applicationDelegateArray;

@property (nonatomic, assign) BOOL isLaunch;
@property (nonatomic, assign) BOOL isWait;

@property (nonatomic) dispatch_queue_t handleURLQueue;
@property (nonatomic) dispatch_semaphore_t handleURLSemaphore;

- (void)handleExternalUrl:(NSURL *)url;

@end

@implementation YPPRouterURLAdapter (UIApplication)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 勾取UIApplication的设置委托对象方法
        [YPPRouterHookService hookRawClass:[UIApplication class]
                             rawSEL:@selector(setDelegate:)
                        targetClass:[YPPRouterURLAdapter class]
                             newSEL:@selector(ym_setDelegate:)
                     placeHolderSEL:@selector(ym_setDelegateP:)];
    });
    
    //监听应用前置
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActiveHandler:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

+ (void)didBecomeActiveHandler:(NSNotification *)notif {
    [YPPRouterURLAdapter sharedAdapter].isLaunch = YES;
    dispatch_semaphore_signal([YPPRouterURLAdapter sharedAdapter].handleURLSemaphore);
}

- (void)ym_setDelegate:(id<UIApplicationDelegate>)delegate {
    
    [YPPRouterURLAdapter sharedAdapter].applicationDelegate = delegate;
    
    [self ym_setDelegate:delegate];
}

- (void)ym_setDelegateP:(id<UIApplicationDelegate>)delegate {
    
}

@end

@implementation YPPRouterURLAdapter (UIApplicationDelegate)

- (BOOL)ym_application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    [[YPPRouterURLAdapter sharedAdapter] handleExternalUrl:url];
    
    return [self ym_application:application handleOpenURL:url];
}

- (BOOL)ym_application:(UIApplication *)application handleOpenURLP:(NSURL *)url {
    return YES;
}

- (BOOL)ym_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    [[YPPRouterURLAdapter sharedAdapter] handleExternalUrl:url];
    
    return [self ym_application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (BOOL)ym_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotationP:(id)annotation {
    return YES;
}

- (BOOL)ym_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    [[YPPRouterURLAdapter sharedAdapter] handleExternalUrl:url];
    
    return [self ym_application:app openURL:url options:options];
}

- (BOOL)ym_application:(UIApplication *)app openURL:(NSURL *)url optionsP:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return YES;
}

- (BOOL)ym_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    
    NSString *activityType = userActivity.activityType;
    if ([activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        
        [[YPPRouterURLAdapter sharedAdapter] handleExternalUrl:userActivity.webpageURL];
    }
    
    return [self ym_application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}

- (BOOL)ym_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandlerP:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return YES;
}

@end

@implementation YPPRouterURLAdapter

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isLaunch = NO;
        self.isWait = NO;
        self.handleURLQueue = dispatch_queue_create("YPPRouterHandleURLQueue", DISPATCH_QUEUE_SERIAL);
        self.handleURLSemaphore = dispatch_semaphore_create(0);
    }
    return self;
}

+ (instancetype)sharedAdapter {
    static id _adapter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _adapter = [[self alloc] init];
    });
    return _adapter;
}

- (void)setApplicationDelegate:(id<UIApplicationDelegate>)applicationDelegate {
    
    if (!self.applicationDelegateArray) {
        self.applicationDelegateArray = [NSMutableArray array];
    }
    
    //将appdelegate加入数组，从来没有过的才能hook
    Class delegateClass = [applicationDelegate class];
    
    BOOL hasHooked = NO;
    
    for (Class obj in self.applicationDelegateArray) {
        
        if ([applicationDelegate isKindOfClass:obj]) {
            
            hasHooked = YES;
            break;
        }
    }
    
    if (delegateClass && !hasHooked) {
        
        _applicationDelegate = applicationDelegate;
        
        [self hookApplicationDelegate];
        
        [self.applicationDelegateArray addObject:delegateClass];
    }
}

- (void)hookApplicationDelegate {
    
    if (self.applicationDelegate) {
        
        // 勾取application:handleOpenURL:方法
        [YPPRouterHookService hookRawClass:[self.applicationDelegate class]
                             rawSEL:@selector(application:handleOpenURL:)
                        targetClass:[self class]
                             newSEL:@selector(ym_application:handleOpenURL:)
                     placeHolderSEL:@selector(ym_application:handleOpenURLP:)];
        
        // 勾取application:openURL:sourceApplication:annotation:
        [YPPRouterHookService hookRawClass:[self.applicationDelegate class]
                             rawSEL:@selector(application:openURL:sourceApplication:annotation:)
                        targetClass:[self class]
                             newSEL:@selector(ym_application:openURL:sourceApplication:annotation:)
                     placeHolderSEL:@selector(ym_application:openURL:sourceApplication:annotationP:)];
        
        // 若在iOS9以上,则勾取application:openURL:options:
        [YPPRouterHookService hookRawClass:[self.applicationDelegate class]
                             rawSEL:@selector(application:openURL:options:)
                        targetClass:[self class]
                             newSEL:@selector(ym_application:openURL:options:)
                     placeHolderSEL:@selector(ym_application:openURL:optionsP:)];
        
        // 若在iOS8以上,勾取application:continueUserActivity:restorationHandler:
        [YPPRouterHookService hookRawClass:[self.applicationDelegate class]
                             rawSEL:@selector(application:continueUserActivity:restorationHandler:)
                        targetClass:[self class]
                             newSEL:@selector(ym_application:continueUserActivity:restorationHandler:)
                     placeHolderSEL:@selector(ym_application:continueUserActivity:restorationHandlerP:)];
    }
}

- (void)handleURL:(NSURL *)url withExtensionDic:(NSDictionary *)extensionDic {
    [[YPPRouterURLParser sharedInstance] parseURL:url withExtensionDic:extensionDic];
}

- (void)handleExternalUrl:(NSURL *)url {
    BOOL needHandle = NO;
    if ([[YPPRouter shared].delegate respondsToSelector:@selector(autoProcessExternalUrl:)]) {
        needHandle = [[YPPRouter shared].delegate autoProcessExternalUrl:url];
    }
    if (needHandle) {
        if (self.isLaunch) {
            [self handleURL:url withExtensionDic:nil];
        } else {
            // 等待APP前置后，再处理url
            dispatch_async(self.handleURLQueue, ^{
                if (!self.isWait) {
                    dispatch_semaphore_wait(self.handleURLSemaphore, DISPATCH_TIME_FOREVER);
                    self.isWait = YES;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self handleURL:url withExtensionDic:nil];
                });
            });
        }
    }
}

@end
