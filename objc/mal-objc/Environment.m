//
//  Environment.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Environment.h"

@interface Environment ()
@property (readonly) NSMutableDictionary *data;
@end

@implementation Environment

- (instancetype)initWithOuter:(Environment *)outer {
    if (self = [super init]) {
        _outer = outer;
        _data = [NSMutableDictionary new];
    }
    return self;
}

- (void)set:(id)anObject forSymbol:(NSString *)symbol {
    self.data[symbol] = anObject;
}

- (Environment *)findEnvironmentForSymbol:(NSString *)symbol {
    if ([self.data objectForKey:symbol] != nil) {
        return self;
    }
    return self.outer;
}

- (id)getObjectForSymbol:(NSString *)symbol {
    Environment *env = [self findEnvironmentForSymbol:symbol];
    
    if (env == nil) {
        @throw [NSException exceptionWithName:@"NoSymbolFound" 
                                       reason:@"Symbol not found in the environment chain" 
                                     userInfo:@{@"symbol" : symbol}];
    }
    
    return env.data[symbol];
}

@end
