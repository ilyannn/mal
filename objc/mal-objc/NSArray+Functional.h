//
//  Created by ilya on 10/31/13.
//  Copyright (c) 2013 Ilya Nikokoshev. All rights reserved.
//

/// Functional enhancements for an array class.
@interface NSArray (Functional)

/// Create an array of a form f(0), f(1), ..., which ends when nil is returned.
+ (NSArray *)arrayWithFactory:(id (^)(NSUInteger idx))func;

/// Create a new array by applying func; skip any nil avlues.
- (NSArray *)arrayByMapping:(id (^)(id))func;

/// Filter an array by using a boolean function.
- (NSArray *)arrayByFiltering:(BOOL (^)(id))func;

/// Use for an array of dictionaries.
- (NSArray *)arrayByTakingDictionaryKey:(NSString *)key;

/// Reduce an array using 2-associative function func.
- (id)objectByReducing:(id (^)(id, id))func;

@end
