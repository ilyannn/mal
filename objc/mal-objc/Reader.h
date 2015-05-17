//
//  Reader.h
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString * Token;

@interface Reader : NSObject
- (instancetype)initWithTokens:(NSArray *)tokens;

@property (readonly, nonatomic) Token peek;
- (Token)next;
@end
