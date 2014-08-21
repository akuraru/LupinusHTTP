//
// Created by azu on 2014/08/19.
//


#import <Foundation/Foundation.h>

@interface LupinusHTTPRequest : NSObject <NSURLSessionDataDelegate>
typedef void (^LupinusHTTPRequestResponseRawData)(NSURLRequest *request, NSURLResponse *response, NSData *data, NSError *error);

typedef void (^LupinusHTTPRequestResponseString)(NSURLRequest *request, NSURLResponse *response, NSString *string, NSError *error);

typedef void (^LupinusHTTPRequestResponseJSON)(NSURLRequest *request, NSURLResponse *response, id JSON, NSError *error);

+ (instancetype)requestWithSession:(NSURLSession *) session dataTask:(NSURLSessionDataTask *) dataTask;

#pragma mark - operation task

- (void)resume;
- (void)cancel;

#pragma mark - response methods

// response json
- (void)responseJSON:(LupinusHTTPRequestResponseJSON) complete;

// response string
- (void)responseString:(LupinusHTTPRequestResponseString) complete;

// response raw NSData
- (void)responseRawData:(LupinusHTTPRequestResponseRawData) complete;
@end