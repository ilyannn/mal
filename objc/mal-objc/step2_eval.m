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
#import "Types.h"

#import "Function.h"
#import "NSArray+Functional.h"

@interface REPL ()
@property (readonly) NSMutableDictionary *environment;
@end

id READ(NSString *line) {
    return [[[Reader alloc] initWithString:line] read_form];
}

NSString *PRINT(id ast) {
    Printer *printer = [[Printer alloc] init];
    return [printer print:ast readably:YES];
}

@implementation REPL

- (instancetype)init {
    if (self = [super init]) {
        _environment = [NSMutableDictionary new];
        [self fillEnvironment];
    }
    return self;
}

- (void)fillEnvironment {
    self.environment[@"+"] = [Function operationWithIntegers:^NSInteger(NSInteger a, NSInteger b) 
    {
        return a + b;
    }];
    self.environment[@"-"] = [Function operationWithIntegers:^NSInteger(NSInteger a, NSInteger b) 
                              {
                                  return a - b;
                              }];
    self.environment[@"/"] = [Function operationWithIntegers:^NSInteger(NSInteger a, NSInteger b) 
                              {
                                  return a / b;
                              }];
    self.environment[@"*"] = [Function operationWithIntegers:^NSInteger(NSInteger a, NSInteger b) 
                              {
                                  return a * b;
                              }];
}

- (id)eval_ast:(id)ast {
    if ([ast isKindOfClass:[Symbol class]]) {        // Symbol
        return self.environment[[ast name]];
    } else if ([ast isKindOfClass:[NSMutableArray class]]) { // Vector
        return [[ast arrayByMapping:^id(id sub) {
            return [self eval:sub];
        }] mutableCopy];
    } else if ([ast isKindOfClass:[NSArray class]]) { // List
        return [ast arrayByMapping:^id(id sub) {
            return [self eval:sub];
        }];
    } else if ([ast isKindOfClass:[NSDictionary class]]) { // Map
        NSArray *keys = [ast allKeys];
        
        NSArray *evalobjs = [keys arrayByMapping:^id(id key) {
            return [self eval:ast[key]];
        }];
        
        return [NSDictionary dictionaryWithObjects:evalobjs forKeys:keys];
    } {
        return ast;
    }
}

- (id)eval:(id)ast {
    if (![ast isKindOfClass:[NSArray class]] || [ast isKindOfClass:[NSMutableArray class]]) {
        return [self eval_ast:ast];
    }
    
    NSArray *evaluated = [self eval_ast:ast];
    
    Function *op = [evaluated firstObject];
    if (![op isKindOfClass:[Function class]]) {
        @throw [NSException exceptionWithName:@"FunctionRequired" 
                                       reason:@"Symbol that is a known function must be the first in a list" 
                                     userInfo:nil];
    }
    
    NSRange range = NSMakeRange(1, evaluated.count - 1);
    return [op evaluateWithArguments:[evaluated subarrayWithRange:range]];
}

- (NSString *)rep:(NSString *)line {
    return PRINT([self eval:READ(line)]);
}

@end

