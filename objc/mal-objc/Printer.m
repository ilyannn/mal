//
//  Printer.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Printer.h"
#import "NSArray+Functional.h"

@implementation NSString (Printer)

- (NSString *)print {
    return self;
}

@end

@implementation NSNumber (Printer)

- (NSString *)print {
    static dispatch_once_t onceToken;
    static NSNumberFormatter *numberFormatter;
    dispatch_once(&onceToken, ^{
        numberFormatter = [NSNumberFormatter new];
    });
    NSAssert(numberFormatter, @"Couldn't create printer number formatter");
    
    return [numberFormatter stringFromNumber:self];
}

@end

@implementation NSArray (Printer)

- (NSString *)print {
    return [NSString stringWithFormat:@"(%@)", [[self arrayByMapping:^id(id object) {
        return [object print];
    }] componentsJoinedByString:@" "]];
}

@end

@implementation Printer

- (NSString *)print:(id)object {
    return [object print];
}

@end
