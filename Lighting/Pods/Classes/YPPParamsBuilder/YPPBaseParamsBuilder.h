//
//  YPPBaseParamsBuilder.h
//  YPP-router
//
//  Created by lujinhui on 2020/1/10.
//

#import "YPPParamsBuilder.h"

#import "YPPNavigationConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface YPPBaseParamsBuilder : YPPParamsBuilder

// 自定义参数
@property (nonatomic, strong) id customParams;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
// 回调
@property (nonatomic, strong) void (^callback) ();
#pragma clang diagnostic pop

// 设置页面弹出样式
- (void)setNavigationConfigBlock:(void(^)(YPPNavigationConfig *config))navigationConfigBlock;

@end

NS_ASSUME_NONNULL_END
