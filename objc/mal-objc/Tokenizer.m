//
//  Reader.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Tokenizer.h"
#import "Consumers.h"

@interface Tokenizer() <CharacterConsuming>
@property (readonly, copy) NSScanner *scanner;
@property (readwrite) Token peek;
@property (readonly) NSCharacterSet *rightDelimiters;
@end

@implementation Tokenizer

+ (NSMutableCharacterSet *)skipSet {
    NSMutableCharacterSet *skips = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [skips addCharactersInString:@","];
    return skips;    
}

- (instancetype)initWithString:(NSString *)string 
                    delimiters:(NSCharacterSet *)delimiterSet 
{
    if (self = [super init]) {
        _scanner = [[NSScanner alloc] initWithString:string];        
        _scanner.charactersToBeSkipped = [[self class] skipSet];
        
        _rightDelimiters = delimiterSet;
    }
    return self;
}

- (NSString *)description {
    NSString *string = self.scanner.string;
    NSRange range = NSMakeRange(self.scanner.scanLocation, 0);
    return [string stringByReplacingCharactersInRange:range withString:_peek ? @"⬅︎": @"➡︎"];
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
    if (self.scanner.atEnd) {
        return;
    }
    
    for (; [consumer continueConsumingAt:self.currentCharacter]; self.scanner.scanLocation++) {}
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

    while (self.currentCharacter == ';') {
        [self consumeCharactersWithConsumer:[EndLineConsumer new]];
        [self consumeCharactersWithConsumer:self];    
    }

    if (self.currentCharacter == '"') {
        StringConsumer *consumer = [StringConsumer new];
        [self consumeCharactersWithConsumer:consumer];
        return consumer.result;
    }

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
