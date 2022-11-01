//
//  YPPRouterURLParser.h
//  YPP-router
//
//  Created by lujinhui on 2020/1/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 解析URL，执行Action
@interface YPPRouterURLParser : NSObject

+ (instancetype)sharedInstance;

- (void)parseURL:(NSURL *)url withExtensionDic:(nullable NSDictionary *)extensionDic;

- (id)oldPerformAction:(NSString *)action target:(NSString *)target withParams:(NSDictionary *)params;

- (id)safePerformAction:(SEL)action target:(NSObject *)target params:(id)params;

@end

NS_ASSUME_NONNULL_END
