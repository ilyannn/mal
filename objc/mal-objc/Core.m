//
//  Core.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 18/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Core.h"
#import "Function.h"

#import "NSArray+Functional.h"


@implementation Core

#pragma mark - Environment

- (instancetype)init {
    if (self = [super init]) {        
        _bindings = [[[self selectorDict] allKeys] // fix order
                     arrayByMapping:^id(NSString *key) {
                         return [Symbol symbolWithName:key];
                     }];
    }
    return self;
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
             @"=": @"equals:",
             @"slurp": @"slurp:",
             @"read-string": @"readString:",
             @"pr-str":@"pr_str:",
             @"str":@"str:",
             @"prn":@"prn:",
             @"println":@"println:",
             @"cons":@"cons:", 
             @"concat":@"concat:",
             @"first":@"first:",
             @"rest":@"rest:",
             @"nth":@"nth:",
             };
}

- (NSArray *)operations {
    return [[self bindings] arrayByMapping:^id(Symbol *sym) {        
        SEL sel = NSSelectorFromString([self selectorDict][sym.name]);
        NSMethodSignature *sign = [self methodSignatureForSelector:sel];
        
        BOOL numberOp = sign.numberOfArguments == 4;
        
        return [[Function alloc] initWithBody:^ id(id args) {
            
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
                return [[Truth alloc] initWithTruth:retval];
            }
        }];
    }];
}


#pragma mark - List functions

- (NSNumber *)count:(NSArray *)args {
    id first = [args firstObject];
    if ([first isEqualTo:[NSNull null]]) {
        return 0;
    }
    return @([first count]);
}

- (NSArray *)list:(NSArray *)args {
    return args;
}

- (Truth *)listQ:(id)args {
    id first = [args firstObject];
    return [[Truth alloc] initWithTruth:[first isKindOfClass:[NSArray class]]];
}

- (Truth *)emptyQ:(id)args {
    id first = [args firstObject];
    return [[Truth alloc] initWithTruth: [first count] != 0];
}

- (Truth *)equals:(id)args {
    id first = args[0];
    id second = args[1];
    return [[Truth alloc] initWithTruth: [first isEqualTo:second]];
}

- (NSArray *)cons:(id)args {
    RequireElement(1, args, [NSArray class]);
    return [@[args[0]] arrayByAddingObjectsFromArray:args[1]];
}

- (NSArray *)concat:(id)args {
    NSMutableArray *result = [NSMutableArray new];
    for (NSArray *arg in args) {
        [result addObjectsFromArray:arg];
    }
    return [result copy];
}

- (id)first:(id)args {
    RequireElement(0, args, [NSArray class]);
    id result = [args[0] firstObject];
    return result ?: [NSNull null];
}

- (NSArray *)rest:(id)args {
    RequireElement(0, args, [NSArray class]);
    
    if ([args[0] count] == 0) {
        return @[];
    }
    
	NSRange range = NSMakeRange(1, [args[0] count] - 1);
    return [args[0] subarrayWithRange:range];
}

- (id)nth:(id)args {
    RequireElement(0, args, [NSArray class]);
    RequireElement(1, args, [NSNumber class]);
    return args[0][[args[1] integerValue]];
}


#pragma mark - Integer functions

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

#pragma mark - String and file functions

- (NSString *)slurp:(id)args {
    RequireElement(0, args, [NSString class]);                   
    NSString *filename = [args firstObject];
    
    NSError *error;    
    NSString *str = [NSString stringWithContentsOfFile:filename 
                                              encoding:NSUTF8StringEncoding 
                                                 error:&error];
    
    if (error) {
        @throw [NSException exceptionWithName:@"FileAccessProblem" 
                                       reason:@"Couldn't read a file" 
                                     userInfo:@{@"error" : error,
                                                @"filename" : filename
                }];
    }
    
    return str;
}

- (id)readString:(id)args {
    RequireElement(0, args, [NSString class]);                   
    return READ([args firstObject]);
}

- (NSString *)printArgs:(id)args sep:(NSString *)sep readably:(BOOL)readably {
    NSArray *printed = [args arrayByMapping:^id(id sub) {
        return [sub printReadably:readably];
    }];
    return [printed componentsJoinedByString:sep];
}

- (NSString *)pr_str:(id)args {
    return [self printArgs:args sep:@" " readably:YES];
}

- (NSString *)str:(id)args {
    return [self printArgs:args sep:@"" readably:NO];
}

- (void)outputString:(NSString *)string {
    printf("%s", [string UTF8String]);
}

- (NSNull *)prn:(id)args {
    [self outputString:[self printArgs:args sep:@" " readably:YES]];
    return [NSNull null];
}

- (NSNull *)println:(id)args {
    [self outputString:[self printArgs:args sep:@" " readably:NO]];
    return [NSNull null];
}


@end
