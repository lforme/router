//
//  NSString+CharValue.m
//  Lighting
//
//  Created by lujinhui on 2020/8/31.
//

#import "NSString+CharValue.h"

@implementation NSString (CharValue)

- (signed char)charValue {
    return [@([self integerValue]) charValue];
}

@end
