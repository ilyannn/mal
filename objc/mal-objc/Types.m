//
//  Symbol.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 18/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Types.h"
#import "NSArray+Functional.h"
#import "Printer.h"

@implementation NSString (Type)

- (BOOL)truthValue {
    return true;
}

- (NSString *)print {
    return [self printReadably:NO];
}

- (NSString *)printReadably:(BOOL)print_readably {
    NSString *expanded = print_readably ? [[[self 
                                             stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"]
                                            stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]                           
                                           stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] 
    : self;
    
    return [NSString stringWithFormat:@"\"%@\"", expanded];
}

@end

@implementation NSNull (Type)

- (NSString *)print {
    return @"nil";
}

- (BOOL)truthValue {
    return false;
}

@end


@implementation NSNumber (Type)

- (NSNumberFormatter *)numberFormatter {    
    static dispatch_once_t onceToken;
    static NSNumberFormatter *numberFormatter;
    dispatch_once(&onceToken, ^{
        numberFormatter = [NSNumberFormatter new];
    });
    
    NSAssert(numberFormatter, @"Couldn't create printer number formatter");    
    return numberFormatter;
}

- (NSString *)print {
	return [self.numberFormatter stringFromNumber:self];
}

- (BOOL)truthValue {
    return true;
}

@end

@implementation NSArray (Type)

- (NSString *)print {
    return [self printReadably:NO];
}

- (NSString *)printReadably:(BOOL)print_readably withLeft:(NSString *)left right:(NSString *)right {
    return [NSString stringWithFormat:@"%@%@%@", left, [[self arrayByMapping:^id(id object) {
        return [[Printer new] print:object readably:print_readably];
    }] componentsJoinedByString:@" "], right];
}

- (NSString *)printReadably:(BOOL)print_readably {
    return [self printReadably:print_readably withLeft:@"(" right:@")"];
}

- (BOOL)truthValue {
    return true;
}

- (BOOL)isVector {
    return NO;
}

@end


@implementation NSMutableArray (Type)

- (NSString *)printReadably:(BOOL)print_readably {
    return [self printReadably:print_readably withLeft:@"[" right:@"]"];
}

- (BOOL)isVector {
    return YES;
}

@end


@implementation NSDictionary (Type)

- (NSString *)print {
    return [self printReadably:NO];
}

- (NSString *)printReadably:(BOOL)print_readably {
    return [NSString stringWithFormat:@"{%@}", [[[self allKeys] arrayByMapping:^id(id key) {
        Printer *printer = [Printer new];
        return [NSString stringWithFormat:@"%@ %@", 
                [printer print:key readably:print_readably],
                [printer print:self[key] readably:print_readably]];
    }] componentsJoinedByString:@" "]];
}

- (BOOL)truthValue {
    return true;
}

@end


@implementation Named

- (BOOL)truthValue {
    return true;
}

- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        _name = name;
    }
    return self;
}

- (NSString *)print {
    @throw @"not implemented";
}

- (NSUInteger)hash {
    return [self.description hash];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[self class]] 
    	&& [self isKindOfClass:[object class]] 
        && [self.name isEqual:[object name]];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithName:self.name];
}

@end

@implementation Symbol 

+ (instancetype)symbolWithName:(NSString *)name {
    return [[self alloc] initWithName:name];
}

- (NSString *)print {
    return self.name;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"(symbol)%@", self.name];
}

@end

@implementation Keyword

+ (instancetype)keywordWithName:(NSString *)name {
    return [[self alloc] initWithName:name];
}

- (NSString *)print {
    return [NSString stringWithFormat:@":%@", self.name];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(kw)%@", self.name];
}

@end

@implementation Truth

- (BOOL)truthValue {
    return self.truth;
}

- (instancetype)initWithTruth:(BOOL)truth {
    if (self = [super init]) {
        _truth = truth;
    }
    return self;
}

- (NSString *)print {
    return self.truthValue? @"true" : @"false";
}

- (NSString *)description {
    return [self print];
}

- (NSUInteger)hash {
    return [@(self.truthValue) hash];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[Truth class]] && (self.truthValue == [object truthValue]);
}

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithTruth:self.truthValue];
}

@end

