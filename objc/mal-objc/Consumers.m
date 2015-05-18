//
//  StringConsumer.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 18/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Consumers.h"

@interface EndLineConsumer ()
@property BOOL atEnd;
@end

@implementation EndLineConsumer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _atEnd = NO;
    }
    return self;
}

- (BOOL)continueConsumingAt:(unichar)ch {
    if (self.atEnd) {
        return NO;
    }
    
    self.atEnd = ch == '\n';
    return YES;
}

@end

@interface StringConsumer () {
    NSMutableString *_result;
}
@property BOOL atStart;
@property BOOL atEnd;
@property BOOL inSpecial;
@end

@implementation StringConsumer

- (NSString *)result {
    return [_result copy];
}

- (instancetype)init
{
    if (self = [super init]) {
        _result = [NSMutableString new];
        _atStart = YES;
        _atEnd = NO;
        _inSpecial = NO;
    }
    return self;
}

- (BOOL)continueConsumingAt:(unichar)ch {
    unichar chstr[2];
    chstr[0] = ch;
    chstr[1] = 0;
    
    if (self.atEnd) {
        return NO;
    }
    
    if (self.inSpecial) {
        switch (ch) {
            case 'n':
                chstr[0] = '\n';
                break;
                
            default:    
                chstr[0] = ch;
        }
        
    } else {
        
        switch (ch) {
            case '\\':
                self.inSpecial = YES;
                return YES;

            case '"':
                if (!self.atStart) {
                	self.atEnd = YES;
                }
        }
    }
    
    self.atStart = NO;

    [_result appendString:[NSString stringWithCharacters:chstr length:1]];
    return YES;
}

@end
