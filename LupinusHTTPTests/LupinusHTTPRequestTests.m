//
// Created by azu on 2014/08/20.
//


#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <XCTestCase-RunAsync/XCTestCase-RunAsync.h>
#import <OHHTTPStubs/OHHTTPStubsResponse+JSON.h>
#import "LupinusHTTP.h"
#import "LupinusHTTPRequest.h"
#import <OCHamcrest/OCHamcrest.h>

@interface LupinusHTTPRequest (mock)
@property(nonatomic, strong) NSURLRequest *request;
@property(nonatomic, strong) NSURLSessionDataTask *dataTask;
@property(nonatomic, strong) NSError *response_error;
@property(nonatomic, strong) NSData *response_data;
@property(nonatomic, strong) dispatch_queue_t queue;
@end

@interface LupinusHTTPRequestTests : XCTestCase
@end

@implementation LupinusHTTPRequestTests {
}
- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
    [OHHTTPStubs removeAllStubs];
}

- (void)shouldReturnJSONObject:(id) JSONObject {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithJSONObject:JSONObject statusCode:200 headers:@{@"Content-Type" : @"text/json"}];
    }];
}

- (void)shouldReturnString:(id) string {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[string dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:@{}];
    }];
}

- (void)shouldReturnError {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:@"test" code:400 userInfo:@{}]];
    }];
}

#pragma mark - cancel

- (void)test_request_cancel {
    [self runAsyncWithBlock:^(AsyncDone done) {
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [[OHHTTPStubsResponse responseWithJSONObject:@{} statusCode:200 headers:nil]
                requestTime:5.0 responseTime:5.0];
        }];
        LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get"];
        // cancel request
        [httpRequest responseJSON:^(NSURLRequest *request, NSURLResponse *response, id JSON, NSError *error) {
            XCTFail(@"don't call");// *1
        }];
        [httpRequest cancel];
        XCTAssertEqual(httpRequest.dataTask.state, NSURLSessionTaskStateCanceling);
        // add queue and done(
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                done();
            });
        });
    }];
}

#pragma mark - common

- (void)test_response_in_main_thread {
    [self runAsyncWithBlock:^(AsyncDone done) {
        LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get"];
        [httpRequest responseJSON:^(NSURLRequest *request, NSURLResponse *response, id JSON, NSError *error) {
            XCTAssert([NSThread isMainThread]);
            done();
        }];
    }];
}

- (void)test_response_is_not_chunk_data {
    NSArray *jsonObject = @[
        @1, @2, @3, @4, @5
    ];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        // @selector(URLSession:dataTask:didReceiveData:)'s data is chunk data.
        return [[OHHTTPStubsResponse responseWithJSONObject:jsonObject statusCode:200 headers:@{@"Content-Type" : @"text/json"}]
            requestTime:0 responseTime:1];
    }];
    [self runAsyncWithBlock:^(AsyncDone done) {
        LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get"];
        // should get all data as json
        [httpRequest responseJSON:^(NSURLRequest *request, NSURLResponse *response, id JSON, NSError *error) {
            HC_assertThat(JSON, HC_is(HC_equalTo(jsonObject)));
            done();
        }];
    }];
}

- (void)test_when_status_code_400_then_error_is_filled {
    NSDictionary *expected = @{@"a" : @1};

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithJSONObject:expected statusCode:400 headers:@{@"Content-Type" : @"text/json"}];

    }];
    [self runAsyncWithBlock:^(AsyncDone done) {
        LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get"];
        // should get all data as json
        [httpRequest responseJSON:^(NSURLRequest *request, NSURLResponse *response, id JSON, NSError *error) {
            HC_assertThat(error, HC_is(HC_notNilValue()));
            HC_assertThat(JSON, HC_is(HC_equalTo(expected)));
            done();
        }];
    }];
}

- (void)test_when_status_code_403_then_error_is_filled_string_too {
    NSString *expected = @"test";

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[expected dataUsingEncoding:NSUTF8StringEncoding] statusCode:403 headers:@{}];

    }];
    [self runAsyncWithBlock:^(AsyncDone done) {
        LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/status/403"];
        // should get all data as json
        [httpRequest responseString:^(NSURLRequest *request, NSURLResponse *response, NSString *string, NSError *error) {
            HC_assertThat(error, HC_is(HC_notNilValue()));
            HC_assertThat(string, HC_is(HC_equalTo(expected)));
            done();
        }];
    }];
}

#pragma mark - json

- (void)test_responseJSON_should_return_JSON {
    NSDictionary *expected = @{
        @"result" : @"OK"
    };
    [self shouldReturnJSONObject:expected];
    [self runAsyncWithBlock:^(AsyncDone done) {
        LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get"];
        [httpRequest responseJSON:^(NSURLRequest *request, NSURLResponse *response, id JSON, NSError *error) {
            HC_assertThat(JSON, HC_is(HC_equalTo(expected)));
            done();
        }];
    }];
}

- (void)test_responseJSON_when_error_should_return_error {
    [self shouldReturnError];
    [self runAsyncWithBlock:^(AsyncDone done) {
        LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get"];
        [httpRequest responseJSON:^(NSURLRequest *request, NSURLResponse *response, id JSON, NSError *error) {
            HC_assertThat(JSON, HC_is(HC_nilValue()));
            HC_assertThat(error, HC_isA([NSError class]));
            done();
        }];
    }];
}

- (void)test_responseJSON_when_non_valid_json_should_return_parse_error {
    [self shouldReturnString:@"non json"];
    [self runAsyncWithBlock:^(AsyncDone done) {
        LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get"];
        [httpRequest responseJSON:^(NSURLRequest *request, NSURLResponse *response, id JSON, NSError *error) {
            HC_assertThat(JSON, HC_is(HC_nilValue()));
            HC_assertThat(error, HC_isA([NSError class]));
            done();
        }];
    }];
}

#pragma mark - string

- (void)test_responseString_return_string {
    NSString *expected = @"result";
    [self shouldReturnString:expected];
    [self runAsyncWithBlock:^(AsyncDone done) {
        LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get"];
        [httpRequest responseString:^(NSURLRequest *request, NSURLResponse *response, NSString *string, NSError *error) {
            HC_assertThat(string, HC_is(HC_equalTo(expected)));
            HC_assertThat(error, HC_is(HC_nilValue()));
            done();
        }];
    }];
}

- (void)test_responseString_when_error_return_error {
    [self shouldReturnError];
    [self runAsyncWithBlock:^(AsyncDone done) {
        LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get" query:@{
            @"key" : @"value"
        }];
        [httpRequest responseJSON:^(NSURLRequest *request, NSURLResponse *response, id JSON, NSError *error) {
            HC_assertThat(JSON, HC_is(HC_nilValue()));
            HC_assertThat(error, HC_isA([NSError class]));
            done();
        }];
    }];
}

#pragma mark - rawData

- (void)test_responseRawData_return_nsdata {
    NSString *expected = @"result";
    [self shouldReturnString:expected];
    [self runAsyncWithBlock:^(AsyncDone done) {
        LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get"];
        [httpRequest responseRawData:^(NSURLRequest *request, NSURLResponse *response, NSData *rawData, NSError *error) {
            NSString *string = [[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding];
            HC_assertThat(string, HC_is(HC_equalTo(expected)));
            HC_assertThat(error, HC_is(HC_nilValue()));
            done();
        }];
    }];
}

- (void)test_responseRawData_when_error_return_error {
    [self shouldReturnError];
    [self runAsyncWithBlock:^(AsyncDone done) {
        LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get"];
        [httpRequest responseRawData:^(NSURLRequest *request, NSURLResponse *response, NSData *rawData, NSError *error) {
            XCTAssert([rawData isKindOfClass:[NSData class]]);
            XCTAssert(rawData.length == 0);
            HC_assertThat(error, HC_isA([NSError class]));
            done();
        }];
    }];
}
@end
