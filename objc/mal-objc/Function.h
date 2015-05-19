//
//  Operation.h
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"

void Require(BOOL condition, NSString *explanation, id args);
void RequireList(id args);
id RequireElement(NSUInteger index, NSArray *args, Class type);

@interface Function : NSObject <Type>

@property (strong, readonly) id(^body)(id);

+ (instancetype)operationWithIntegers:(NSInteger(^)(NSInteger, NSInteger))body;
- (instancetype)initWithBody:(id(^)(id))body;
- (id)evaluateWithArguments:(id)arguments;

@end

@class Environment;

@interface DefinedFunction: Function
- (instancetype)initWithBody:(id(^)(id))body params:(NSArray *)params env:(Environment *)env ast:(id)ast NS_DESIGNATED_INITIALIZER;

@property (readwrite) BOOL is_macro;

@property (readonly) id ast;
@property (readonly) NSArray *params;
@property (readonly) Environment *env;
@end