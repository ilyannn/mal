//
//  StringConsumer.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 18/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "StringConsumer.h"

@interface StringConsumer () {
    NSMutableString *_result;
}
@property (getter=areAtStart) BOOL atStart;
@property (getter=areAtEnd) BOOL atEnd;
@property (getter=areInSpecial) BOOL inSpecial;
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
        _inSpecial = NO;
    }
    return self;
}

- (BOOL)continueConsumingAt:(unichar)ch {
    unichar chstr[2];
    chstr[1] = 0;
    
    if (self.atStart) {
        self.atStart = NO;
        return YES;    
    }
    
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
            case '"':
                self.atEnd = YES;
                return YES;
                
            case '\\':
                self.inSpecial = YES;
                // fallthrough
                
            default:    
                chstr[0] = ch;
        }
    }
    
    [_result appendString:[NSString stringWithCharacters:chstr length:1]];
    return YES;
}

@end
