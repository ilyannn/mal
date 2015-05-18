//
//  Printer.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "Printer.h"
#import "Types.h"

@implementation Printer

- (NSString *)print:(id)object {
    return [object print];
}

- (NSString *)print:(id)object readably:(BOOL)print_readably {
    if (print_readably && [object respondsToSelector:@selector(printReadably:)]) {
        return [object printReadably: YES];
    } else {
        return [object print];
    }
}

@end
