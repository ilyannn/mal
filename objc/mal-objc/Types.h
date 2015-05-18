//
//  Symbol.h
//  mal_objc
//
//  Created by Ilya Nikokoshev on 18/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MALType <NSObject, NSCopying>
- (NSString *)print;
- (BOOL)truthValue;
@end

@interface NSString(MALType) <MALType>
@end

@interface NSNull(MALType) <MALType>
@end

@interface NSNumber(MALType) <MALType>
@end

@interface NSArray(MALType) <MALType>
@end

@interface Symbol: NSObject <MALType>
+ (instancetype)symbolWithName:(NSString *)name;
- (instancetype)initWithName:(NSString *)name;
@property (readonly) NSString *name;
@end

@interface Truth: NSObject <MALType>
- (instancetype)initWithTruth:(BOOL)truth;
@property (readonly) BOOL truth;
@end