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
@end

@implementation Reader

#pragma mark - Construction

- (instancetype)initWithString:(NSString *)line {
    if (self = [super init]) {
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
    if (![token length]) {
        return nil;
    }
    
    if ([token isLeftParen]) {
        return [self read_list];
    } else {
        return [self read_atom];
    }
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
    
    if ([token isEqual: @"nil"]) {
        return [NSNull null];
    } 
    
    if ([token isEqual:@"true"]) {
        return [[Truth alloc] initWithTruth:YES];
    }
    
    if ([token isEqual:@"false"]) {
        return [[Truth alloc] initWithTruth:NO];
    } 
    
    if ([token characterAtIndex:0] == '"') {
        NSRange range = NSMakeRange(1, token.length - 2);
        return [[[[token substringWithRange:range] 
                 stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""]
                 stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"]
        		 stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"]
        ;
         
    }

    NSNumber *number = [self.numberFormatter numberFromString:token];
    return number ?: [[Symbol alloc] initWithName:token];    
}

@end
