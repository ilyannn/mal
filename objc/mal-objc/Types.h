//
//  Symbol.h
//  mal_objc
//
//  Created by Ilya Nikokoshev on 18/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Type <NSObject, NSCopying>
- (NSString *)print;
- (BOOL)truthValue;
@optional 
- (NSString *)printReadably:(BOOL)print_readably;
@end

@interface NSString(Type) <Type>
@end

@interface NSNull(Type) <Type>
@end

@interface NSNumber(Type) <Type>
@end

@interface NSArray(Type) <Type>
@property (readonly, getter=isVector) BOOL vector;
@end

@interface NSMutableArray(Type) <Type>
@end

@interface NSDictionary(Type) <Type>
@end

@interface Named: NSObject
- (instancetype)initWithName:(NSString *)name;
@property (readonly) NSString *name;
@end

@interface Keyword: Named <Type>
+ (instancetype)keywordWithName:(NSString *)name;
@end

@interface Symbol: Named <Type>
+ (instancetype)symbolWithName:(NSString *)name;
@end

@interface Truth: NSObject <Type>
- (instancetype)initWithTruth:(BOOL)truth;
@property (readonly) BOOL truth;
@end