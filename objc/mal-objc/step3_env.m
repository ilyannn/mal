//
//  MALInterpreter.m
//  mal-objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

//
//  main.m
//  mal-objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "REPL.h"

#import "Reader.h"
#import "Printer.h"

#import "Operation.h"
#import "Environment.h"
#import "NSArray+Functional.h"

@interface REPL ()
@end

id READ(NSString *line) {
    return [[[Reader alloc] initWithString:line] read_form];
}

NSString *PRINT(id ast) {
    Printer *printer = [[Printer alloc] init];
    return [printer print:ast];
}

@implementation REPL

- (void)fillEnvironment:(Environment *)environment {
    [environment set: [Operation operationWithIntegers:
                            ^NSInteger(NSInteger a, NSInteger b) {
        return a + b;
    }] forSymbol: @"+"];
     
    [environment set: [Operation operationWithIntegers:
                            ^NSInteger(NSInteger a, NSInteger b) {
                                return a - b;
                            }] forSymbol: @"-"];
    
    [environment set: [Operation operationWithIntegers:
                            ^NSInteger(NSInteger a, NSInteger b) {
                                return a * b;
                            }] forSymbol: @"*"];
    
    [environment set: [Operation operationWithIntegers:
                            ^NSInteger(NSInteger a, NSInteger b) {
                                return a / b;
                            }] forSymbol: @"/"];

}

- (id)eval_ast:(id)ast env:(Environment *)env {
    if ([ast isKindOfClass:[NSString class]]) {        // Symbol
        return [env getObjectForSymbol:ast];
    } else if ([ast isKindOfClass:[NSArray class]]) { // List
        return [ast arrayByMapping:^id(id sub) {
            return [self eval:sub env:env];
        }];
    } else {
        return ast;
    }
}

- (id)eval:(id)ast env:(Environment *)env{
    
    if (![ast isKindOfClass:[NSArray class]]) {
        return [self eval_ast:ast env:env];
    }
    
    if ([[ast firstObject] isEqual:@"def!"]) {
        id def = [self eval_ast:ast[2] env:env];
        [env set:def forSymbol:ast[1]];
        return def;
    }
    
    if ([[ast firstObject] isEqual:@"let*"]) {
        Environment *child = [[Environment alloc] initWithOuter:env];
        for (NSInteger index = 0; index < [ast[1] count];) {
            NSString *symbol = ast[1][index++];
            id expr = ast[1][index++];
            [child set:[self eval:expr env:child] forSymbol:symbol];
        }
        return [self eval:ast[2] env:child];
    }

    NSArray *evaluated = [ast arrayByMapping:^id(id sub) {
        return [self eval_ast:sub env:env];
    }];
    
    Operation *op = [evaluated firstObject];
    if (![op isKindOfClass:[Operation class]]) {
        @throw [NSException exceptionWithName:@"FunctionRequired" 
                                       reason:@"Symbol that is a known function must be the first in a list" 
                                     userInfo:nil];
    }
    
    NSRange range = NSMakeRange(1, evaluated.count - 1);
    return [op evaluateWithArguments:[evaluated subarrayWithRange:range]];
}

- (NSString *)rep:(NSString *)line {
    Environment *environment = [Environment new];
    [self fillEnvironment:environment];
    return PRINT([self eval:READ(line) env:environment]);
}

@end

