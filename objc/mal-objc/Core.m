//
//  Core.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 18/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Core.h"
#import "Operation.h"

#import "NSArray+Functional.h"

@implementation Core

- (instancetype)init {
    if (self = [super init]) {
        _bindings = [[self selectorDict] allKeys]; // fix order
    }
    return self;
}

- (id)count:(id)args {
    id first = [args firstObject];
    if ([first isEqualTo:[NSNull null]]) {
        return 0;
    }
    return @([first count]);
}

- (id)list:(id)args {
    return args;
}

- (id)listQ:(id)args {
    id first = [args firstObject];
    return [NSNumber numberWithBool:[first isKindOfClass:[NSArray class]]];
}

- (id)emptyQ:(id)args {
    id first = [args firstObject];
    return [NSNumber numberWithBool:[first count] != 0];
}

- (id)equals:(id)args {
    id first = args[0];
    id second = args[1];
    return [NSNumber numberWithBool:[first isEqualTo:second]];
}

- (NSInteger)add:(NSInteger)first to:(NSInteger)second {
    return first + second;
}

- (NSInteger)subtractFrom:(NSInteger)first value:(NSInteger)second {
    return first - second;
}

- (NSInteger)multiply:(NSInteger)first with:(NSInteger)second {
    return first * second;
}

- (NSInteger)divide:(NSInteger)first by:(NSInteger)second {
    return first / second;
}

- (BOOL)less:(NSInteger)first than:(NSInteger)second {
    return first < second;
}

- (BOOL)lessEq:(NSInteger)first than:(NSInteger)second {
    return first <= second;
}

- (BOOL)greater:(NSInteger)first than:(NSInteger)second {
    return first > second;
}

- (BOOL)greaterEq:(NSInteger)first than:(NSInteger)second {
    return first >= second;
}

- (NSDictionary *)selectorDict {
    return @{
      @"count": @"count:", 
       @"list": @"list:", 
      @"list?": @"listQ:", 
     @"empty?": @"emptyQ:", 
          @"<": @"less:than:",
          @">": @"greater:than:",
          @"<=": @"lessEq:than:",
          @">=": @"greaterEq:than:",
          @"+": @"add:to:", 
          @"-": @"subtractFrom:value:",
          @"*": @"multiply:with:",
          @"/": @"divide:by:", 
          @"=": @"equals:"};
}

- (NSArray *)operations {
    return [[self bindings] arrayByMapping:^id(NSString *name) {        
        SEL sel = NSSelectorFromString([self selectorDict][name]);
        NSMethodSignature *sign = [self methodSignatureForSelector:sel];
	
        BOOL numberOp = sign.numberOfArguments == 4;
        
        return [[Operation alloc] initWithBody:^ id(id args) {
            
            // This has a retain cycle.
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sign];
            inv.selector = sel;
            inv.target = self;
            
            if (!numberOp) {
                [inv setArgument:&args atIndex:2];
            } else { 
                NSInteger first = [RequireElement(0, args, [NSNumber class]) integerValue];
                NSInteger second = [RequireElement(1, args, [NSNumber class]) integerValue];
                
                [inv setArgument:&first atIndex:2];
                [inv setArgument:&second atIndex:3];
            } 
            
            [inv invoke];
            
            if (!numberOp) {
                void *retval;
                [inv getReturnValue:&retval];
                return (__bridge id)retval;
            } else if (*sign.methodReturnType != 'c'){
                NSInteger retval;
                [inv getReturnValue:&retval];
                return [NSNumber numberWithInteger:retval];
            } else {
                BOOL retval;
                [inv getReturnValue:&retval];
                return [NSNumber numberWithBool:retval];
            }
        }];
    }];
}

@end
