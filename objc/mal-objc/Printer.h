//
//  Printer.h
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Printable <NSObject>
- (NSString *)print;
@end

@interface NSString(Printer) <Printable>
@end

@interface NSNumber(Printer) <Printable>
@end

@interface NSArray(Printer) <Printable>
@end

@interface Printer : NSObject
- (NSString *)print:(id)object;
@end
