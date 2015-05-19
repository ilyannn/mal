//
//  Quasiquoter.h
//  mal_objc
//
//  Created by Ilya Nikokoshev on 19/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Symbol;

@interface Quasiquoter : NSObject
@property (readonly) Symbol *quote;
@property (readonly) Symbol *quasiquote;
@property (readonly) Symbol *unquote;
@property (readonly) Symbol *splice_unquote;
@property (readonly) Symbol *concat;
@property (readonly) Symbol *cons;

- (id)quasiquote:(id)ast;
@end
