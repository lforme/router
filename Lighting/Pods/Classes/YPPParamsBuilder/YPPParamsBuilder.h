//
//  YPPParamsBuilder.h
//  YPP-router
//
//  Created by lujinhui on 2020/1/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YMKeyValue <NSObject>

- (NSDictionary <NSString *, NSString *>*)ym_replacedKeyFromPropertyName;

@end

@interface YPPParamsBuilder : NSObject <YMKeyValue>

@property (nonatomic, strong) NSMutableDictionary *declarationDic;

/// 传入builder block，生成字典
/// @param builderBlock builder 的类 必须为 YPPParamsBuilder 的子类
- (NSDictionary *)dictionaryWithBuilderBlock:(void (^)(id builder))builderBlock;

@end

@interface UIViewController (YPPParamsBuilder)

- (void)ypp_setValuesForKeysWithParams:(NSDictionary<NSString *,id> *)keyedValues;

@end

NS_ASSUME_NONNULL_END
