//
//  MALInterpreter.m
//  mal-objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

//
//  main.m
//  mal-objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "REPL.h"

#import "Reader.h"
#import "Printer.h"

id READ(NSString *line) {
    return [[[Reader alloc] initWithString:line] read_form];
}

NSString *PRINT(id ast) {
    Printer *printer = [[Printer alloc] init];
    return [printer print:ast readably:YES];
}

id EVAL(id ast) {
    return ast;
}

@implementation REPL

- (NSString *)rep:(NSString *)line {
    return PRINT(EVAL(READ(line)));
}

@end

