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

id READ(NSString *line) {
    return line;
}

NSString *PRINT(id ast) {
    return ast;
}

id EVAL(id ast) {
    return ast;
}

@implementation REPL

- (NSString *)rep:(NSString *)line {
    return PRINT(EVAL(READ(line)));
}

@end

