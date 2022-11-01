//
//  YPPRouterMapLoader.h
//  Lighting
//
//  Created by lujinhui on 2020/3/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YPPRouterMapLoader : NSObject

@property (nonatomic, copy, readonly) NSDictionary *schemeMaps;

@property (nonatomic, strong, readonly) NSMutableDictionary *oldSchemeMaps;

+ (instancetype)sharedLoader;

- (void)loadMaps;

#pragma mark - 兼容旧方法

- (void)loadQuickPageWithArray:(NSArray *)pageInArray;

- (void)addPlugin:(NSString *)pluginName toBlock:(void(^)(NSDictionary *params))block;

@end

NS_ASSUME_NONNULL_END
