//
//  REPL.h
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface REPL: NSObject
- (NSString *)rep:(NSString *)line;
@end
