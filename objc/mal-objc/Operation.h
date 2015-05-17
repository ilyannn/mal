//
//  Operation.h
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Printer.h"

void Require(BOOL condition, NSString *explanation, id args);
void RequireList(id args);
id RequireElement(NSUInteger index, NSArray *args, Class type);

@interface Operation : NSObject

@property (strong) id(^body)(id);

+ (instancetype)operationWithIntegers:(NSInteger(^)(NSInteger, NSInteger))body;

- (instancetype)initWithBody:(id(^)(id))body;

- (id)evaluateWithArguments:(id)arguments;

@end

@interface Operation(Printer) <Printable>
@end