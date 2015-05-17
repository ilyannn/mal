//
//  Reader+Tokens.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Reader+Tokens.h"

@interface NSString (Tokens)
- (NSArray *)tokenize;
@end

@implementation NSString (Tokens)

- (NSArray *)tokenize {
    static dispatch_once_t onceToken;
    static NSString *pattern = @"[\\s,]*(~@|[\\[\\]{}()'`~^@]|\"(?:\\\\.|[^\\\\\"])*\"|;.*|[^\\s\\[\\]{}('\"`,;)]*);";
    
    static NSRegularExpression *regexp;
    dispatch_once(&onceToken, ^{
        regexp = [NSRegularExpression regularExpressionWithPattern:pattern 
                                                           options:0 error:nil];
    });
    
    NSAssert(regexp, @"Couldn't create regexp");        
    
    NSRange range = NSMakeRange(0, [self length]);
    NSArray *matches = [regexp matchesInString:self 
                                       options:0
                                         range:range
                        ];
    
    NSMutableArray *tokens = [NSMutableSet new];
    for (NSTextCheckingResult *match in matches) {
        Token token = [self substringWithRange:[match range]];
        [tokens addObject:token];
    }
    
    return [tokens copy];
}

@end


@implementation Reader(Tokens)

- (instancetype)initWithString:(NSString *)string {
    return [self initWithTokens:[string tokenize]];
}

@end
