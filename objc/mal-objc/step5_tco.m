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

#import "Function.h"
#import "Environment.h"
#import "Core.h"
#import "NSArray+Functional.h"

@interface REPL ()
@property (readonly) Environment *globalEnvironment;
@end

id READ(NSString *line) {
    return [[[Reader alloc] initWithString:line] read_form];
}

NSString *PRINT(id ast) {
    Printer *printer = [[Printer alloc] init];
    return [printer print:ast];
}

@implementation REPL

- (instancetype)init {
    if (self = [super init]) {
        Core *core = [Core new];
        _globalEnvironment = [[Environment alloc] initWithOuter:nil 
                                                          binds:core.bindings 
                                                          exprs:core.operations];
        [self rep:@"(def! not (fn* (a) (if a false true)))"];
   }
    return self;
}

- (id)eval_ast:(id)ast env:(Environment *)env {
    if ([ast isKindOfClass:[Symbol class]]) {        // Symbol
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

    if ([[ast firstObject] isKindOfClass:[Symbol class]]) {
        NSArray *specials = @[@"def!", @"let*", @"do", @"if", @"fn*"];
        
        __block __weak id wself = self;
        
        id def, first;
        NSInteger index;
        Environment *child;
        NSArray *binds;
        id expr;
        
        
        switch ([specials indexOfObject:[[ast firstObject] name]]) {
            case 0: // def!
                def = [self eval:ast[2] env:env];
                [env set:def forSymbol:ast[1]];
                return def;
                
            case 1: // let*
                child = [[Environment alloc] initWithOuter:env];
                for (NSInteger index = 0; index < [ast[1] count];) {
                    Symbol *symbol = ast[1][index++];
                    id expr = ast[1][index++];
                    [child set:[self eval:expr env:child] forSymbol:symbol];
                }
                return [self eval:ast[2] env:child];
                
            case 2: // do
                return [[ast arrayByMapping:^id(id sub) {
                    return [self eval_ast:sub env:env];
                }] lastObject];
                
            case 3: // if
                first = [self eval:ast[1] env:env];
                index = [first truthValue] ? 2 : 3;
                return [self eval:ast[index] env:env];
                
            case 4: // fn*
                binds = ast[1];
                expr = ast[2];
                return [[Function alloc] initWithBody:^id(id args) {
                    Environment *child = [[Environment alloc] initWithOuter:env 
                                                                      binds:binds 
                                                                      exprs:args];
                    return [wself eval:expr env:child];
                    
                }];            
        }
        
    }
    NSArray *evaluated = [self eval_ast:ast env:env];
    
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
    return PRINT([self eval:READ(line) env:self.globalEnvironment]);
}

@end

