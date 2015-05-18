//
//  Environment.h
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Symbol;

@interface Environment : NSObject
@property (readonly) Environment *outer; 

- (instancetype)init;
- (instancetype)initWithOuter:(Environment *)outer;
- (instancetype)initWithOuter:(Environment *)outer binds:(NSArray *)binds exprs:(NSArray *)exprs NS_DESIGNATED_INITIALIZER;

- (void)set:(id)anObject forSymbol:(Symbol *)symbol;
- (Environment *)findEnvironmentForSymbol:(Symbol *)symbol;
- (id)getObjectForSymbol:(Symbol *)symbol;

@end
