//
//  YPPParamsBuilder.m
//  YPP-router
//
//  Created by lujinhui on 2020/1/4.
//

#import "YPPParamsBuilder.h"
#import <objc/runtime.h>
#import "MJExtension.h"

@interface YPPParamsBuilder ()

@end

@implementation YPPParamsBuilder

- (instancetype)init
{
    self = [super init];
    if (self) {
        _declarationDic = [NSMutableDictionary new];
    }
    return self;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    
    NSString *sel_string = NSStringFromSelector(sel);
    
    if ([sel_string hasPrefix:@"set"]) {
        class_addMethod(self, sel, (IMP) addSetterFunc, "v@:@");
    }
    return YES;
}

/// 添加setter方法，将key/value保存到字典中
void addSetterFunc(id self, SEL _cmp, id value) {
    
    YPPParamsBuilder *typedSelf = (YPPParamsBuilder *) self;
    
    NSMutableDictionary *backingStore = typedSelf.declarationDic;
    
    NSString *key = NSStringFromSelector(_cmp);
    NSMutableString *mutableKey = [key mutableCopy];

    [mutableKey deleteCharactersInRange:NSMakeRange(mutableKey.length - 1, 1)];
    [mutableKey deleteCharactersInRange:NSMakeRange(0, 3)];
    NSString *lower = [[mutableKey substringToIndex:1] lowercaseString];
    [mutableKey replaceCharactersInRange:NSMakeRange(0, 1) withString:lower];

    if (value) {
        [backingStore setObject:value forKey:mutableKey];
    } else {
        [backingStore removeObjectForKey:mutableKey];
    }
}

- (NSDictionary *)dictionaryWithBuilderBlock:(void (^)(id builder))builderBlock {
    
    if (builderBlock) {
        builderBlock(self);
    }
    // 遍历builder的属性，返回字典
    return [self mj_keyValues];
}

@end

@implementation UIViewController (YPPParamsBuilder)

- (void)ypp_setValuesForKeysWithParams:(NSDictionary<NSString *,id> *)keyedValues {
    
    [self mj_setKeyValues:keyedValues];
}

@end
