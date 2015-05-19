//
//  Reader.h
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString * Token;

@protocol CharacterConsuming <NSObject>
- (BOOL)continueConsumingAt:(unichar)ch;
@end

/**
 Splits a string into tokens.
 
 Characters that are in the delimiters set will be returned one character
 at a time. Other characters will be grouped into tokens.
 */
@interface Tokenizer : NSObject
+ (NSMutableCharacterSet *)skipSet;

- (instancetype)initWithString:(NSString *)string 
                    delimiters:(NSCharacterSet *)delimiterSet;

@property (readonly, nonatomic) unichar currentCharacter;
- (void)consumeCharactersWithConsumer:(id <CharacterConsuming>)consumer;

@property (readonly, nonatomic) Token peek;
- (Token)next;
@end

