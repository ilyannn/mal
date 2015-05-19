//
//  Environment.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Environment.h"

#import "Types.h"

@interface Environment ()
@property (readonly) NSMutableDictionary *data;
@end

@implementation Environment

- (instancetype)init {
    return [self initWithOuter:nil];
}

- (instancetype)initWithOuter:(Environment *)outer {
    return [self initWithOuter:outer binds:nil exprs:nil];
}

- (instancetype)initWithOuter:(Environment *)outer binds:(NSArray *)binds exprs:(NSArray *)exprs {
    if (self = [super init]) {
        _outer = outer;
        NSInteger all = [binds indexOfObject:[[Symbol alloc] initWithName:@"&"]];
        
        if (all != NSNotFound) {            
            NSRange range = NSMakeRange(all, exprs.count - all);
            NSArray *rest = [exprs subarrayWithRange:range];            
            
            range = NSMakeRange(0, all);
            exprs = [[exprs subarrayWithRange:range] arrayByAddingObject:rest];

            NSMutableArray *mbinds = [binds mutableCopy];
            [mbinds removeObjectAtIndex:all];
            binds = [mbinds copy];
		}
        
        _data = [NSMutableDictionary dictionaryWithObjects:exprs forKeys:binds];
    }
    return self;
    
}

- (void)set:(id)anObject forSymbol:(Symbol *)symbol {
    self.data[symbol] = anObject;
}

- (Environment *)findEnvironmentForSymbol:(Symbol *)symbol {
    if ([self.data objectForKey:symbol] != nil) {
        return self;
    }
    return [self.outer findEnvironmentForSymbol:symbol];
}

- (id)getObjectForSymbol:(Symbol *)symbol {
    Environment *env = [self findEnvironmentForSymbol:symbol];
    
    if (env == nil) {
        @throw [NSException exceptionWithName:@"NoSymbolFound" 
                                       reason:@"Symbol not found in the environment chain" 
                                     userInfo:@{@"symbol" : symbol}];
    }
    
    id result = env.data[symbol];
    NSAssert(result != nil, @"Something went wrong");
    return result;
}

@end
