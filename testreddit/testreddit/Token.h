//
//  Token.h
//  testreddit
//
//  Created by Alexander on 6/14/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

#ifndef Token_h
#define Token_h


#import <Foundation/Foundation.h> 
@interface Token : NSObject
@property NSString *access_token;
@property NSString *token_type;
@property NSString *device_id;
@property int expires_in;
@property NSString *scope;

- (BOOL)initWithJson:(NSDictionary *)jsonDictionary;

@end
#endif /* Token_h */
