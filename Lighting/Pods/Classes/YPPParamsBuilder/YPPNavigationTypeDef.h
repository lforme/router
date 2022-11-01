//
//  YNNavigationTypeDef.h
//  Pods
//
//  Created by lujinhui on 2020/1/11.
//

#ifndef YNNavigationTypeDef_h
#define YNNavigationTypeDef_h

/// 导航条显示状态
typedef NS_ENUM(NSUInteger, YNNavigationBarStatus) {
    YNNavigationBarStatusUnknown = 0, // 未知
    YNNavigationBarStatusDefault, // 显示导航条，默认
    YNNavigationBarStatusHidden, // 隐藏导航条
};

/// 页面旋转状态
typedef NS_ENUM(NSUInteger, YNAutorotateStatus) {
    YNAutorotateStatusUnknown, // 未知
    YNAutorotateStatusEnable, // 允许旋转，默认
    YNAutorotateStatusDisable, // 不允许旋转
};

/// 页面弹出方式
typedef NS_ENUM(NSUInteger, YNNavigationTransitionStyle) {
    YNNavigationTransitionStyleUnknown = 0, // 未知
    YNNavigationTransitionStyleMiddle, // 中间弹出
    YNNavigationTransitionStyleTop, // 顶部弹出
    YNNavigationTransitionStyleLeft, // 左侧弹出
    YNNavigationTransitionStyleBottom, // 底部弹出
    YNNavigationTransitionStyleRight, // 右侧弹出，默认
};

/// 页面显示方式
typedef NS_ENUM(NSUInteger, YNScreenStyle) {
    YNScreenStyleUnknown = 0, // 未知
    YNScreenStyleFull, // 默认
    YNScreenStyleCustom, // 将VC添加到一个透明VC上，底部弹出
};

/// 触发跳过pop状态
typedef NS_ENUM(NSUInteger, YNNeedTriggerSkipAtPopStatus) {
    YNNeedTriggerSkipAtPopUnknown = 0, // 未知
    YNNeedTriggerSkipAtPopEnable, // 触发跳过pop操作
    YNNeedTriggerSkipAtPopDisable // 不触发，默认
};

/// 跳过pop状态
typedef NS_ENUM(NSUInteger, YNNeedSkipPopStatus) {
    YNNeedSkipPopStatusUnknown = 0, // 未知
    YNNeedSkipPopStatusEnable, // 跳过pop
    YNNeedSkipPopStatusDisable // 不跳过，默认
};

/// 页面默认方向
typedef NS_ENUM(NSUInteger, YNInterfaceOrientation) {
    YNInterfaceOrientationUnknown            = UIDeviceOrientationUnknown,
    YNInterfaceOrientationPortrait           = UIDeviceOrientationPortrait,
    YNInterfaceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
    YNInterfaceOrientationLandscapeLeft      = UIDeviceOrientationLandscapeRight,
    YNInterfaceOrientationLandscapeRight     = UIDeviceOrientationLandscapeLeft
};

/// 页面支持的方向
typedef NS_OPTIONS(NSUInteger, YNInterfaceOrientationMask) {
    YNInterfaceOrientationMaskPortrait = (1 << YNInterfaceOrientationPortrait),//2
    YNInterfaceOrientationMaskLandscapeLeft = (1 << YNInterfaceOrientationLandscapeLeft),//16
    YNInterfaceOrientationMaskLandscapeRight = (1 << YNInterfaceOrientationLandscapeRight),//8
    YNInterfaceOrientationMaskPortraitUpsideDown = (1 << YNInterfaceOrientationPortraitUpsideDown),//4
    YNInterfaceOrientationMaskLandscape = (YNInterfaceOrientationMaskLandscapeLeft | YNInterfaceOrientationMaskLandscapeRight),//24
    YNInterfaceOrientationMaskAll = (YNInterfaceOrientationMaskPortrait | YNInterfaceOrientationMaskLandscapeLeft | YNInterfaceOrientationMaskLandscapeRight | YNInterfaceOrientationMaskPortraitUpsideDown),//30
    YNInterfaceOrientationMaskAllButUpsideDown = (YNInterfaceOrientationMaskPortrait | YNInterfaceOrientationMaskLandscapeLeft | YNInterfaceOrientationMaskLandscapeRight),//26
};

#endif /* YNNavigationTypeDef_h */
