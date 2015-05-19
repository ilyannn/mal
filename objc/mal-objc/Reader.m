//
//  Reader+Read.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Reader.h"

#import "Tokenizer.h"
#import "Types.h"

Token const RightParen = @")]";
Token const LeftParen  = @"([";
Token const Comma      = @",";
Token const Quote      = @"\'";

@implementation NSString (SafeFirst)
- (unichar)safeFirstCharacter {
    if ([self length] == 0) {
        return 0;
    } else {
        return [self characterAtIndex:0];
    }
}
@end


@implementation NSString (Parens)

- (BOOL)isRightParen {
    return [RightParen rangeOfString:self].location != NSNotFound;
}

- (BOOL)isLeftParen {
    return [LeftParen rangeOfString:self].location != NSNotFound;
}

@end

@interface Reader()
@property Tokenizer *tokenizer;
@property Symbol *quote;
@end

@implementation Reader

#pragma mark - Construction

- (instancetype)initWithString:(NSString *)line {
    if (self = [super init]) {
        _quote = [[Symbol alloc] initWithName:@"quote"];
        _tokenizer = [[Tokenizer alloc] initWithString:line delimiters:[[self class] delimiterSet]];
    }
    return self;
}

+ (NSCharacterSet *)delimiterSet {
        static dispatch_once_t onceToken;
        static NSCharacterSet *delimiters;
        dispatch_once(&onceToken, ^{
            NSMutableCharacterSet *chars = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
            
            [chars addCharactersInString:RightParen];
            [chars addCharactersInString:LeftParen];
            [chars addCharactersInString:Comma];
            [chars addCharactersInString:Quote];
            
            delimiters = [chars copy];
        });
        return delimiters;

}

#pragma mark - Helpers

- (void)consume:(NSString *)choices {
    id next = [self.tokenizer next];
    if ([choices rangeOfString:next].location == NSNotFound) {
        @throw [NSException exceptionWithName:@"ReaderUnexpectedToken" 
                                       reason:@"Unexpected token"
                                     userInfo:@{@"expected": choices, 
                                                @"found": next ?: [NSNull null]}
                ];;
    }
}

- (NSNumberFormatter *)numberFormatter {
    static dispatch_once_t onceToken;
    static NSNumberFormatter *numberFormatter;
    dispatch_once(&onceToken, ^{
        numberFormatter = [NSNumberFormatter new];
    });
    
    NSAssert(numberFormatter, @"Couldn't create number formatter");
    return numberFormatter;
}

#pragma mark - Reading

- (id)read_form {
    Token token = self.tokenizer.peek;
    switch ([token safeFirstCharacter]) {
        case 0: 
            return nil;
            
        case '\'':
            return [self read_quote];

        case '(':
        case '[':
            return [self read_list];
            
        default:
            return [self read_atom];
    }
}

- (id)read_quote {
    [self consume:@"\'"];
    return @[self.quote, [self read_form]];
}

- (id)read_list {
    [self consume:LeftParen];
    
    NSMutableArray *elements = [NSMutableArray new];
    while(![self.tokenizer.peek isRightParen]) {
        id element = [self read_form]; 
        if (![element isEqualTo:Comma]) {
        	[elements addObject:element];
        }
    }
    
    [self consume:RightParen];

    return [elements copy];
}

- (id)read_atom {
    
    Token token = [self.tokenizer next];
    
    if ([token characterAtIndex:0] == '"') {
        NSRange range = NSMakeRange(1, token.length - 2);
        return [token substringWithRange:range];
    } 
    
    if ([token isEqual:@"true"]) {
        return [[Truth alloc] initWithTruth:YES];
    }
    
    if ([token isEqual:@"false"]) {
        return [[Truth alloc] initWithTruth:NO];
    } 
    
    NSNumber *number = [self.numberFormatter numberFromString:token];
    return number ?: [[Symbol alloc] initWithName:token];    
}

@end
