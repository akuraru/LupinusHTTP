//
// Created by azu on 2014/08/20.
//


#import <XCTest/XCTest.h>
#import "LupinusHTTPRequest.h"
#import "LupinusHTTP.h"
#import "OHHTTPStubsResponse.h"
#import "OHHTTPStubs.h"
#import "OHHTTPStubsResponse+JSON.h"
#import "XCTestCase-RunAsync.h"

#define HC_SHORTHAND

#import <OCHamcrest/OCHamcrest.h>


@interface LupinusHTTPTests : XCTestCase
@end

@implementation LupinusHTTPTests {
}
- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
    [OHHTTPStubs removeAllStubs];
}

- (void)test_request_return_LupinusHTTPRequest {
    LupinusHTTPRequest *request = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get" query:@{} body:nil];
    (request, isA([LupinusHTTPRequest class]));
}

- (void)test_request_should_request_http {
    [self runAsyncWithBlock:^(AsyncDone done) {
        [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get"];
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            done();// catch http request
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithJSONObject:@{} statusCode:200 headers:@{}];
        }];
    }];
}
@end

