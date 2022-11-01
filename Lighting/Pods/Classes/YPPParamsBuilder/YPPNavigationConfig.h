//
//  YPPNavigationConfig.h
//  YPPNavigation
//
//  Created by lujinhui on 2020/1/14.
//

#import <Foundation/Foundation.h>

#import "YPPNavigationTypeDef.h"

NS_ASSUME_NONNULL_BEGIN

@interface YPPNavigationConfig : NSObject

/// 导航条显示状态
@property (nonatomic, assign) YNNavigationBarStatus navigationBarStatus;

/// 页面显示方式
@property (nonatomic, assign) YNScreenStyle screenStyle;

/// 页面旋转状态
@property (nonatomic, assign) YNAutorotateStatus autorotateStatus;

/// 页面默认方向
@property (nonatomic, assign) YNInterfaceOrientation interfaceOrientation;

/// 页面支持的方向
@property (nonatomic, assign) YNInterfaceOrientationMask interfaceOrientationMask;

/// Push风格
@property (nonatomic, assign) YNNavigationTransitionStyle pushStyle;

/// Pop风格
@property (nonatomic, assign) YNNavigationTransitionStyle popStyle;

/// 触发跳过pop状态
@property (nonatomic, assign) YNNeedTriggerSkipAtPopStatus needTriggerSkipAtPopStatus;

/// 跳过pop状态
@property (nonatomic, assign) YNNeedSkipPopStatus needSkipPopStatus;

// url导航控制字段,除了上面的字段外，同样支持以下字段

// 例子: yn://path/path_id?navigationBarStatus=1&pushStyle=4&isLandscape=1

// BOOL isLandscape; 是否横屏
//
// BOOL isHideNavigation; 是否隐藏导航条
//
// BOOL isSupportAutoRotate; 是否自动旋转
//
// BOOL needTriggerSkipAtPop; 是否触发跳过pop
//
// BOOL needSkipPop; 是否需要跳过pop

@end

NS_ASSUME_NONNULL_END
