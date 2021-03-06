//
//  Operation.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Function.h"

void Require(BOOL condition, NSString *explanation, id args) {
    if (!condition) {
        @throw [NSException exceptionWithName:@"OperationRequirement" 
                                       reason:@"Operation requirement not met: " 
                                     userInfo:@{@"arguments": args, 
                                                @"explanation": explanation}
                ];
    }
}

void RequireList(id args) {
    Require([args isKindOfClass:[NSArray class]], @"Must be a list", args);
}

id RequireElement(NSUInteger index, NSArray *args, Class type) {
    Require(args.count > index, @"Require an element to be present", args);
    id element = args[index];
    Require([element isKindOfClass:type], @"Require element to have specified class", args);
    return element;
}

@implementation Function

+ (instancetype)operationWithIntegers:(NSInteger (^)(NSInteger, NSInteger))body {
    return [[self alloc] initWithBody:^id(id args) {
        RequireList(args);
        NSNumber *first = RequireElement(0, args, [NSNumber class]);
        NSNumber *second = RequireElement(1, args, [NSNumber class]);
        return @(body([first integerValue], [second integerValue]));
    }];
}

- (instancetype)initWithBody:(id (^)(id))body {
    if (self = [super init]) {
        _body = body;
    }
    return self;
}

- (id)evaluateWithArguments:(id)arguments {
    return self.body(arguments);
}

- (NSString *)print {
    return @"#<function>";
}

- (BOOL)truthValue {
    return true;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithBody:self.body];
}

@end


@implementation DefinedFunction

- (instancetype)initWithBody:(id (^)(id))body params:(NSArray *)params env:(Environment *)env ast:(id)ast {
    if (self = [super initWithBody:body]) {
        _params = params;
        _env = env;
        _ast = ast;
    }
    return self;
}

@end
