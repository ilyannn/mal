//
//  Quasiquoter.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 19/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Quasiquoter.h"

#import "Types.h"

@implementation Quasiquoter

- (instancetype)init
{
    if (self = [super init]) {
        _quote = [[Symbol alloc] initWithName:@"quote"];
        _quasiquote = [[Symbol alloc] initWithName:@"quasiquote"];
        _concat = [[Symbol alloc] initWithName:@"concat"];
        _cons = [[Symbol alloc] initWithName:@"cons"];
        _unquote = [[Symbol alloc] initWithName:@"unquote"];
        _splice_unquote = [[Symbol alloc] initWithName:@"splice-unquote"];
    }
    return self;
}
- (BOOL)is_pair:(id)ast {
    if (![ast isKindOfClass:[NSArray class]]) {
        return false;
    }
    return [ast count] != 0;
}

- (id)quasiquote:(id)ast {
    if (![self is_pair:ast]) {
        return @[self.quote, ast];
    }
    
    id first = ast[0];
    if ([self.unquote isEqualTo:first]) {
        return ast[1];
    }
    
    NSRange range = NSMakeRange(1, [ast count] - 1);
    id rest = [self quasiquote:[ast subarrayWithRange:range]];
    
    if ([self is_pair:first] && [self.splice_unquote isEqualTo: first[0]]) {
        return @[self.concat, first[1], rest];
    }
    
    return @[self.cons, [self quasiquote:first], rest];
}

@end
