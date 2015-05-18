//
//  Core.h
//  mal_objc
//
//  Created by Ilya Nikokoshev on 18/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Core : NSObject
 /**
 *  Array of Symbol
 */
@property (readonly) NSArray *bindings;
@property (readonly) NSArray *operations;
@end
