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

- (void)test_request_with_query {
    [self runAsyncWithBlock:^(AsyncDone done) {
        [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get" query:@{
            @"key" : @"value"
        }];
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            HC_assertThat(request.URL.absoluteString, HC_equalTo(@"http://httpbin.org/get?key=value"));
            done();// catch http request
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithJSONObject:@{} statusCode:200 headers:@{}];
        }];
    }];
}

- (void)test_request_with_post_body {
    [self runAsyncWithBlock:^(AsyncDone done) {
        [LupinusHTTP request:LupinusMethodPOST URL:@"http://httpbin.org/get" query:@{
            @"key" : @"value"
        } body:@[@1, @2, @3]];
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            HC_assertThat(request.HTTPMethod, HC_equalTo(@"POST"));
            HC_assertThat(request.URL.absoluteString, HC_equalTo(@"http://httpbin.org/get?key=value"));
            // https://github.com/AliSoftware/OHHTTPStubs/wiki/Testing-for-the-request-body-in-your-stubs
            // HC_assertThat(request.HTTPBody, HC_equalTo(@"[1,2,3]"));
            done();// catch http request
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithJSONObject:@{} statusCode:200 headers:@{}];
        }];
    }];
}
@end

