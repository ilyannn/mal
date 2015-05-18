//
//  StringConsumer.h
//  mal_objc
//
//  Created by Ilya Nikokoshev on 18/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tokenizer.h"

@interface StringConsumer : NSObject <CharacterConsuming>
@property (readonly) NSString *result;
@end
