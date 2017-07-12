//
//  Token.h
//  testreddit
//
//  Created by Anna on 6/14/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

#ifndef Token_h
#define Token_h


#import <Foundation/Foundation.h> 

/**
 A class describing token from server.
 */
@interface Token : NSObject

/**
 The token value.
 */
@property NSString *access_token;

/**
 Token type: should be "bearer".
 */
@property NSString *token_type;

/**
 Id of this device.
 */
@property NSString *device_id;

/**
 Amount of seconds after which the token gets expired.
 */
@property int expires_in;

/**
 A list of separated scope strings.
 */
@property NSString *scope;

/**
 Initializes the token from json.

 @param jsonDictionary a dictionary with json.
 @return <#return value description#>
 */
- (BOOL)initWithJson:(NSDictionary *)jsonDictionary;

@end
#endif /* Token_h */
