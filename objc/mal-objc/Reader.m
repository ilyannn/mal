//
//  Reader.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Reader.h"

@interface Reader()
@property (readonly, copy) NSArray *tokens;
@property NSUInteger position;
@end


@implementation Reader

- (instancetype)initWithTokens:(NSArray *)tokens {
    if (self = [super init]) {
        _tokens = [tokens copy];
        _position = 0;
    }
    return self;
}

- (Token)next {
    if (self.position == _tokens.count) {
        return nil;
    }
    return _tokens[_position++];
}

- (Token)peek {
    if (self.position == _tokens.count) {
        return nil;
    }
    return _tokens[_position];
}

@end
