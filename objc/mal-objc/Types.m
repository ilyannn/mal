//
//  Symbol.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 18/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Types.h"
#import "NSArray+Functional.h"

@implementation NSString (Type)

- (BOOL)truthValue {
    return true;
}

- (NSString *)print {
    NSString *expanded = [[self stringByReplacingOccurrencesOfString:@"\\" 
                                                         withString:@"\\\\"]
						       stringByReplacingOccurrencesOfString:@"\"" 
                                                         withString:@"\\\""];
    return [NSString stringWithFormat:@"\"%@\"", expanded];
}

@end

@implementation NSNull (Printer)

- (NSString *)print {
    return @"nil";
}

- (BOOL)truthValue {
    return false;
}

@end


@implementation NSNumber (Printer)

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

@implementation NSArray (Printer)

- (NSString *)print {
    return [NSString stringWithFormat:@"(%@)", [[self arrayByMapping:^id(id object) {
        return [object print];
    }] componentsJoinedByString:@" "]];
}

- (BOOL)truthValue {
    return true;
}

@end


@implementation Symbol

- (BOOL)truthValue {
    return true;
}

+ (instancetype)symbolWithName:(NSString *)name {
    return [[self alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        _name = name;
    }
    return self;
}

- (NSString *)print {
    return self.name;
}

- (NSUInteger)hash {
    return [self.name hash];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[Symbol class]] && [self.name isEqual:[object name]];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithName:self.name];
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

