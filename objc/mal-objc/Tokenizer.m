//
//  Reader.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Tokenizer.h"


@interface Tokenizer()
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

- (Token)scan {
    NSString *read;
    NSUInteger max = [self.scanner.string length];
    
    // Skip manually.
    for (; self.scanner.scanLocation < max; self.scanner.scanLocation ++) {
        if (![self.scanner.charactersToBeSkipped characterIsMember:
              [self.scanner.string characterAtIndex:self.scanner.scanLocation]]) {
            break;
        }
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
