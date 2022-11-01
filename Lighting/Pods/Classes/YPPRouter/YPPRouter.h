//
//  YPPRouter.h
//  YPP-router
//
//  Created by lujinhui on 2020/1/4.
//  Copyright © 2020 lujinhui. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YPPRouterConst.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 旧协议，已废弃
@protocol WebPageControllerCreater <NSObject>

- (UIViewController *)createControllerWithUrl:(NSString *)url NS_DEPRECATED_IOS(1_0, 2_0);

@end

@protocol NavigationGetter <NSObject>

@required
- (UINavigationController *)getCurrentNavigation NS_DEPRECATED_IOS(1_0, 2_0);

@end

@protocol YPPRouterDelegate <NSObject>

@optional
/// 是否自动对外部跳转的url进行处理
/// @param url 外部跳转的url
- (BOOL)autoProcessExternalUrl:(NSURL *)url;

/// 当前路由需要登录
/// @param handler 回调登录状态。返回YES，会继续调用该条路由；返回NO，则中断调用。
- (void)routerNeedLogin:(void(^)(BOOL isLogin))handler;

@end

/// 路由入口
@interface YPPRouter : NSObject

/// 支持本地解析的scheme列表
@property (nonatomic, copy) NSArray<NSString *> *extraSchemeArray;

/// 单例
+ (instancetype)shared;

/// 通过url跳转路由，若extraSchemeArray中包含支持的scheme，则needConvertScheme为yes
/// @param url 需要跳转的url字符串
- (BOOL)processUrl:(NSString *)url;

/// 通过url跳转路由，needConvertScheme为yes时，不校验scheme，直接本地解析
/// @param url 需要跳转的url字符串
/// @param needConvertScheme 是否需要转换成App自身的scheme
- (BOOL)processUrl:(NSString *)url needConvertScheme:(BOOL)needConvertScheme;

/// 为兼容旧方法，将extensionParams拼接到url中
/// @param url 需要跳转的url字符串
/// @param extensionParams 需要拼接的参数字典
- (BOOL)processUrl:(NSString *)url extensionDic:(NSDictionary *)extensionParams;

/// 通过url跳转路由
/// @param urlString 需要跳转的url字符串
/// @param needConvertScheme 是否需要转换成App自身的scheme
/// @param extensionDic 需要拼接的参数字典
- (BOOL)processUrl:(NSString *)urlString
 needConvertScheme:(BOOL)needConvertScheme
      extensionDic:(NSDictionary *)extensionDic;

@property (nonatomic, weak) id<YPPRouterDelegate> delegate;

@property (nonatomic, weak) id<WebPageControllerCreater> webPageCreater  NS_DEPRECATED_IOS(1_0, 2_0);
@property (nonatomic, weak) id<NavigationGetter> navigationGetter  NS_DEPRECATED_IOS(1_0, 2_0);

@end

@interface YPPRouter (Deprecated)

#pragma mark - 兼容旧方法

- (void)addPlugin:(NSString *)pluginName toBlock:(void(^)(NSDictionary *params))block NS_DEPRECATED_IOS(1_0, 2_0, "Use 'processUrl:needConvertScheme:'."); //运行时注册单个plugin

- (void)addQuickPageSchemeArray:(NSArray *)quickPageSchemeArray NS_DEPRECATED_IOS(1_0, 2_0);    //运行时注册简易的nPage的scheme数组

/// 无效方法，始终返回YES
/// @param url 需要检测的url字符串
- (BOOL)canProcessUrl:(NSString *)url NS_DEPRECATED_IOS(1_0, 2_0);

@end

NS_ASSUME_NONNULL_END
