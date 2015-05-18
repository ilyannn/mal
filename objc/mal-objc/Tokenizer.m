//
//  Reader.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Tokenizer.h"


@interface Tokenizer() <CharacterConsuming>
@property (readonly, copy) NSScanner *scanner;
@property (readwrite) Token peek;
@property (readonly) NSCharacterSet *rightDelimiters;
@end

@implementation Tokenizer

- (instancetype)initWithString:(NSString *)string 
                    delimiters:(NSCharacterSet *)delimiterSet 
{
    if (self = [super init]) {
        _scanner = [[NSScanner alloc] initWithString:string];
        _rightDelimiters = delimiterSet;
    }
    return self;
}

- (Token)next {    
    Token next = self.peek;
    _peek = nil;
    return next;    
}

- (Token)peek {
    if (!_peek) {
        _peek = [self scan];
    }
    return _peek;
}

- (unichar)currentCharacter {
    if ([self.scanner isAtEnd]) {
        return 0;
    }
    return [self.scanner.string characterAtIndex:self.scanner.scanLocation];
}

- (void)consumeCharactersWithConsumer:(id<CharacterConsuming>)consumer {    
    // Skip manually.
    for (; !self.scanner.atEnd; self.scanner.scanLocation ++) {
        if (![consumer continueConsumingAt:self.currentCharacter]) {
            break;
        }
    }
}

 /**
 *  Manually skip whitespace.
 */
- (BOOL)continueConsumingAt:(unichar)ch {
    return [self.scanner.charactersToBeSkipped characterIsMember:ch];
}

- (Token)scan {
    NSString *read;
    
    [self consumeCharactersWithConsumer:self];    
    [self.scanner scanUpToCharactersFromSet:self.rightDelimiters intoString: &read];
    
    if ([read length]) {
        return read;
    }
    
    if (self.scanner.atEnd) {
        return nil;
    }
    
    NSRange single = NSMakeRange(self.scanner.scanLocation, 1);
    read = [self.scanner.string substringWithRange:single];
    
    self.scanner.scanLocation++;
    return read;
}


@end
