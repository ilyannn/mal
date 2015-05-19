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

Token const ListLeft    = @"(";
Token const VectorLeft  = @"[";
Token const ListRight   = @")";
Token const VectorRight = @"]";
Token const MapLeft     = @"{";
Token const MapRight    = @"}";

Token const Commenting  = @";";
Token const Quote       = @"\'";
Token const Quasiquote  = @"`";
Token const Unquote     = @"~";
Token const Deref       = @"@";
Token const String      = @"\"";
Token const Key         = @":";
Token const Metadata    = @"^";

Token const True        = @"true";
Token const False       = @"false";


@implementation NSString (SafeFirst)
- (unichar)safeFirstCharacter {
    if ([self length] == 0) {
        return 0;
    } else {
        return [self characterAtIndex:0];
    }
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

            [chars addCharactersInString:MapLeft];
            [chars addCharactersInString:MapRight];
            [chars addCharactersInString:ListLeft];
            [chars addCharactersInString:ListRight];
            [chars addCharactersInString:VectorLeft];
            [chars addCharactersInString:VectorRight];
            
            [chars addCharactersInString:Commenting];
            [chars addCharactersInString:Metadata];
            [chars addCharactersInString:Deref];
            
            [chars addCharactersInString:Quote];
            [chars addCharactersInString:Unquote];
            [chars addCharactersInString:Quasiquote];
            
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

        case '@':
            return [self read_deref];
            
        case '(':
            return [self read_list: NO];

        case '^':
            return [self read_meta];
            
        case '{':
            return [self read_map];

        case '[':
            return [self read_list: YES];
            
        default:
            return [self read_atom];
    }
}

- (id)read_meta {
    [self consume:Metadata];
    NSDictionary *meta = [self read_map];
    return @[self.qq.with_meta, [self read_form], meta];
}

- (id)read_quote {
    [self consume:Quote];
    return @[self.qq.quote, [self read_form]];
}

- (id)read_deref {
    [self consume:Deref];
    return @[self.qq.deref, [self read_form]];
}

- (id)read_unquote {
    [self consume:Unquote];
    
    if ([self.tokenizer.peek isEqualTo:Deref]) {
        [self consume:Deref];
        return @[self.qq.splice_unquote, [self read_form]];
    }
    
    return @[self.qq.unquote, [self read_form]];
}

- (id)read_quasiquote {
    [self consume:Quasiquote];
    return @[self.qq.quasiquote, [self read_form]];
}

- (id)read_list:(BOOL)vector {
    [self consume: vector ? VectorLeft : ListLeft];
    Token done = vector ? VectorRight : ListRight;
    
    NSMutableArray *elements = [NSMutableArray new];

    while(![self.tokenizer.peek isEqualTo:done]) {
        id element = [self read_form]; 
        [elements addObject:element];
    }
    
    [self consume: done];

    return vector ? elements : [elements copy];
}

- (NSDictionary *)read_map {
    [self consume: MapLeft];
    
    NSMutableDictionary *map = [NSMutableDictionary new];
    
    while(![self.tokenizer.peek isEqualTo:MapRight]) {
        id key = [self read_form]; 
        id object = [self read_form]; 
        [map setObject:object forKey:key];
    }
    
    [self consume: MapRight];
    
    return [map copy];
}


- (id)read_atom {
    
    Token token = [self.tokenizer next];
    
    if ([token safeFirstCharacter] == [String safeFirstCharacter]) {
        NSRange range = NSMakeRange(1, token.length - 2);
        return [token substringWithRange:range];
    } 

    if ([token safeFirstCharacter] == [Key safeFirstCharacter]) {
        NSRange range = NSMakeRange(1, token.length - 1);
        return [Keyword keywordWithName:[token substringWithRange:range]];
    }
    
    if ([token isEqual:True]) {
        return [[Truth alloc] initWithTruth:YES];
    }
    
    if ([token isEqual:False]) {
        return [[Truth alloc] initWithTruth:NO];
    } 
    
    NSNumber *number = [self.numberFormatter numberFromString:token];
    return number ?: [Symbol symbolWithName:token];    
}

@end
