//
//  Reader+Read.h
//  mal_objc
//
//  Created by Ilya Nikokoshev on 17/05/15.
//  Copyright (c) 2015 ilyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reader: NSObject
- (instancetype)initWithString:(NSString *)line;
- (id)read_form;
@end
