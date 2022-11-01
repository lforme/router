//
//  YPPBaseParamsBuilder.m
//  YPP-router
//
//  Created by lujinhui on 2020/1/10.
//

#import "YPPBaseParamsBuilder.h"

@interface YPPBaseParamsBuilder ()

@property (nonatomic, strong) YPPNavigationConfig *navigationConfig;

@end

@implementation YPPBaseParamsBuilder

- (void)setNavigationConfigBlock:(void (^)(YPPNavigationConfig * _Nonnull))navigationConfigBlock {
    self.navigationConfig = [[YPPNavigationConfig alloc] init];
    if (navigationConfigBlock) {
        navigationConfigBlock(self.navigationConfig);
    }
}

@end
