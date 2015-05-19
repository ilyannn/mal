//
//  Reader+Read.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Reader.h"

#import "Tokenizer.h"
#import "Quasiquoter.h"
#import "Types.h"

Token const RightParen = @")]";
Token const LeftParen  = @"([";
Token const Commenting = @";";
Token const Quote      = @"\'";
Token const Quasiquote = @"`";
Token const Unquote    = @"~";
Token const AndSplice  = @"@";
Token const String     = @"\"";

Token const True       = @"true";
Token const False      = @"false";


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
@property (readonly) Tokenizer *tokenizer;
@property (readonly) Quasiquoter *qq;
@end

@implementation Reader

#pragma mark - Construction

- (instancetype)initWithString:(NSString *)line {
    if (self = [super init]) {
        _qq = [Quasiquoter new];
        _tokenizer = [[Tokenizer alloc] initWithString:line delimiters:[[self class] delimiterSet]];
    }
    return self;
}

+ (NSCharacterSet *)delimiterSet {
        static dispatch_once_t onceToken;
        static NSCharacterSet *delimiters;
        dispatch_once(&onceToken, ^{
            NSMutableCharacterSet *chars = [Tokenizer skipSet];
            
            [chars addCharactersInString:RightParen];
            [chars addCharactersInString:LeftParen];
            [chars addCharactersInString:Commenting];
            
            [chars addCharactersInString:Quote];
            [chars addCharactersInString:Unquote];
            [chars addCharactersInString:Quasiquote];
            [chars addCharactersInString:AndSplice];
            
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

        case '`':
            return [self read_quasiquote];

        case '~':
            return [self read_unquote];

        case '(':
        case '[':
            return [self read_list];
            
        default:
            return [self read_atom];
    }
}

- (id)read_quote {
    [self consume:Quote];
    return @[self.qq.quote, [self read_form]];
}

- (id)read_unquote {
    [self consume:Unquote];
    
    if ([self.tokenizer.peek isEqualTo:AndSplice]) {
        [self consume:AndSplice];
        return @[self.qq.splice_unquote, [self read_form]];
    }
    
    return @[self.qq.unquote, [self read_form]];
}

- (id)read_quasiquote {
    [self consume:Quasiquote];
    return @[self.qq.quasiquote, [self read_form]];
}

- (id)read_list {
    [self consume:LeftParen];
    
    NSMutableArray *elements = [NSMutableArray new];
    while(![self.tokenizer.peek isRightParen]) {
        id element = [self read_form]; 
        [elements addObject:element];
    }
    
    [self consume:RightParen];

    return [elements copy];
}

- (id)read_atom {
    
    Token token = [self.tokenizer next];
    
    if ([token characterAtIndex:0] == [String safeFirstCharacter]) {
        NSRange range = NSMakeRange(1, token.length - 2);
        return [token substringWithRange:range];
    } 
    
    if ([token isEqual:True]) {
        return [[Truth alloc] initWithTruth:YES];
    }
    
    if ([token isEqual:False]) {
        return [[Truth alloc] initWithTruth:NO];
    } 
    
    NSNumber *number = [self.numberFormatter numberFromString:token];
    return number ?: [[Symbol alloc] initWithName:token];    
}

@end
