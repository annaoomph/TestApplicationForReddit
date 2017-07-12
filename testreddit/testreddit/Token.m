//
//  Token.m
//  testreddit
//
//  Created by Anna on 6/14/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//
#import "Token.h"

@implementation Token

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)initWithJson:(NSDictionary *)jsonDictionary {
    @try {
        [self setValuesForKeysWithDictionary:jsonDictionary];
    }
    @catch (NSException *exception) {
        return false;
    }
    return true;
    
    
}
@end
