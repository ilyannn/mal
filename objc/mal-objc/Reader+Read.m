//
//  Reader+Read.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Reader+Read.h"

@implementation Reader(Read)

- (id)read_form {
    Token token = [self peek];
    if (![token length]) {
        return nil;
    }
    
    switch ([token characterAtIndex:0]) {
        case '(':
            return [self read_list];
            
        default:
            return [self read_atom];
    }
}

- (id)read_list {
    NSMutableArray *elements = [NSMutableArray new];
    while(![[self peek] isEqualTo:@")"]) {
        id element = [self read_form]; 
        [elements addObject:element];
    }
    
    return [elements copy];
}

- (id)read_atom {
    static dispatch_once_t onceToken;
    static NSNumberFormatter *numberFormatter;
    dispatch_once(&onceToken, ^{
        numberFormatter = [NSNumberFormatter new];
    });
    
    NSAssert(numberFormatter, @"Couldn't create number formatter");
    
    Token token = [self peek];
    NSNumber *number = [numberFormatter numberFromString:token];
    if (number) {
        return number;
    } else {
        return token;
    }
}

@end
