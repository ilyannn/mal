//
//  Environment.h
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Environment : NSObject
@property (readonly) Environment *outer; 

- (instancetype)init;
- (instancetype)initWithOuter:(Environment *)outer NS_DESIGNATED_INITIALIZER;

- (void)set:(id)anObject forSymbol:(NSString *)symbol;
- (Environment *)findEnvironmentForSymbol:(NSString *)symbol;
- (id)getObjectForSymbol:(NSString *)symbol;

@end
