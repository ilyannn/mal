//
//  Quasiquoter.h
//  mal_objc
//
//  Created by Ilya Nikokoshev on 19/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Quasiquoter : NSObject
- (id)quasiquote:(id)ast;
@end
