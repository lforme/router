//
//  YPPRouterAdapter.h
//  YPP-router
//
//  Created by lujinhui on 2020/1/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 拦截应用外URL跳转，适配YPPRouter
@interface YPPRouterURLAdapter : NSObject

@property (nonatomic, weak) id<UIApplicationDelegate> applicationDelegate;

@property (nonatomic, strong) NSDictionary *maps;

+ (instancetype)sharedAdapter;

/// 处理url，统一使用适配器入口
/// @param extensionDic 额外的字典，兼容老代码
- (void)handleURL:(NSURL *)url withExtensionDic:(nullable NSDictionary *)extensionDic;

@end

NS_ASSUME_NONNULL_END
