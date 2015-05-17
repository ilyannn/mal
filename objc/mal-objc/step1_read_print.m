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

#import <Foundation/Foundation.h>

#import "Reader.h"

#include <readline/readline.h>
#include <readline/history.h>

#import "Reader.h"
#import "Reader+Tokens.h"
#import "Reader+Read.h"
#import "Printer.h"

NSString * const prompt = @"user> ";  

id READ(NSString *line) {
    Reader *reader = [[Reader alloc] initWithString:line];
    return [reader read_form];
}

NSString *PRINT(id ast) {
    Printer *printer = [[Printer alloc] init];
    return [printer print:ast];
}

id EVAL(id ast) {
    return ast;
}

NSString *rep(NSString *line) {
    return PRINT(EVAL(READ(line)));
}


int main(int argc, const char * argv[]) {
    
    for(;;) {
        @autoreleasepool {
            char *line = readline([prompt UTF8String]);
            if (!line) { break; }
            
            NSString *input = [NSString stringWithUTF8String:line];
            free(line); 
            // release input string
            
            printf("%s\n", [rep(input) UTF8String]);
            // release output string
        }
    } 
    return 0;
}

