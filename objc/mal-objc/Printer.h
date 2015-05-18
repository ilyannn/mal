//
//  Printer.h
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Printer : NSObject
- (NSString *)print:(id)object;
- (NSString *)print:(id)object readably:(BOOL)print_readably;
@end
