//
//  main.m
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import "REPL.h"

#include <readline/readline.h>
#include <readline/history.h>

NSString * const prompt = @"user> ";  

int main(int argc, const char * argv[]) {
    
    REPL *repl = [REPL new];
    
    for(;;) {
        char *line = readline([prompt UTF8String]);
        if (!line) { 
            break; 
        }

        @autoreleasepool {
            @try {
                NSString *input = [NSString stringWithUTF8String:line];
                
                add_history(line);
                free(line); 

                printf("%s\n", [[repl rep:input] UTF8String]);
            }
            @catch (NSException *exception) {
                NSLog(@"Exception occurred: %@", exception);
            }
        } // release output string
    } 
    printf("\n");
    return 0;
}
