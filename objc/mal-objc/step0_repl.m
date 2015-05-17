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

#include <readline/readline.h>
#include <readline/history.h>

NSString * const prompt = @"user> ";  

id READ(NSString *line) {
    return line;
}

NSString *PRINT(id ast) {
    return ast;
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
            
            add_history(line);
            
            NSString *input = [NSString stringWithUTF8String:line];
            free(line); 
            // release input string
            
            printf("%s\n", [rep(input) UTF8String]);
            // release output string
        }
    } 
    printf("\n");
    return 0;
}
