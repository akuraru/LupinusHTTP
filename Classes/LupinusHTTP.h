//
// Created by azu on 2014/08/19.
//


#import <Foundation/Foundation.h>

@class LupinusHTTPRequest;
@class LupinusHTTPSessionTaskDelegate;

typedef NS_ENUM(NSUInteger, LupinusHTTPMethod) {
    LupinusMethodOPTIONS,
    LupinusMethodGET,
    LupinusMethodHEAD,
    LupinusMethodPOST,
    LupinusMethodPUT,
    LupinusMethodPATCH,
    LupinusMethodDELETE,
    LupinusMethodTRACE,
    LupinusMethodCONNECT
};

@interface LupinusHTTP : NSObject
// default : [NSURLSessionConfiguration defaultSessionConfiguration]
+ (instancetype)httpWithSessionConfiguration:(NSURLSessionConfiguration *) sessionConfiguration;

- (LupinusHTTPRequest *)request:(LupinusHTTPMethod) method URL:(NSString *) URLString;

+ (LupinusHTTPRequest *)request:(LupinusHTTPMethod) method URL:(NSString *) URLString;

+ (LupinusHTTPRequest *)request:(LupinusHTTPMethod) method URL:(NSString *) URLString query:(NSDictionary *) query;

+ (LupinusHTTPRequest *)request:(LupinusHTTPMethod) method URL:(NSString *) URLString query:(NSDictionary *) query body:(id) body;

- (LupinusHTTPRequest *)request:(LupinusHTTPMethod) method URL:(NSString *) URLString query:(NSDictionary *) query;

- (LupinusHTTPRequest *)request:(LupinusHTTPMethod) method URL:(NSString *) URLString query:(NSDictionary *) query body:(id) body;

@end