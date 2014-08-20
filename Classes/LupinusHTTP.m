//
// Created by azu on 2014/08/19.
//


#import "LupinusHTTP.h"
#import "LupinusHTTPSessionTaskDelegate.h"
#import "URLQueryBuilder.h"
#import "LupinusHTTPRequest.h"

@interface LupinusHTTP ()
@property(nonatomic, strong) NSURLSession *session;
@property(nonatomic, strong) LupinusHTTPSessionTaskDelegate *delegateManager;
@property(nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;

@end

@implementation LupinusHTTP
- (id)init {
    self = [self initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    if (self == nil) {
        return nil;
    }


    return self;
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *) sessionConfiguration {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.delegateManager = [[LupinusHTTPSessionTaskDelegate alloc] init];
    self.sessionConfiguration = sessionConfiguration;
    self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration
                                 delegate:self.delegateManager
                                 delegateQueue:nil];

    return self;
}

+ (instancetype)httpWithSessionConfiguration:(NSURLSessionConfiguration *) sessionConfiguration {
    return [[self alloc] initWithSessionConfiguration:sessionConfiguration];
}

#pragma mark - request

+ (LupinusHTTPRequest *)request:(LupinusHTTPMethod) method URL:(NSString *) URLString {
    return [[[self alloc] init] request:method URL:URLString];
}

- (LupinusHTTPRequest *)request:(LupinusHTTPMethod) method URL:(NSString *) URLString {
    NSURLRequest *request = [self urlRequest:method URL:URLString query:nil];
    return [self LupinusRequest:request];
}

+ (LupinusHTTPRequest *)request:(LupinusHTTPMethod) method URL:(NSString *) URLString query:(NSDictionary *) query {
    return [[[self alloc] init] request:method URL:URLString query:query];
}

- (LupinusHTTPRequest *)request:(LupinusHTTPMethod) method URL:(NSString *) URLString query:(NSDictionary *) query {
    NSURLRequest *request = [self urlRequest:method URL:URLString query:query];
    return [self LupinusRequest:request];
}

+ (LupinusHTTPRequest *)request:(LupinusHTTPMethod) method URL:(NSString *) URLString query:(NSDictionary *) query body:(id) body {
    return [[[self alloc] init] request:method URL:URLString query:query body:body];
}

- (LupinusHTTPRequest *)request:(LupinusHTTPMethod) method URL:(NSString *) URLString query:(NSDictionary *) query body:(id) body {
    NSURLRequest *request = [self urlRequest:method URL:URLString query:query body:body];
    return [self LupinusRequest:request];
}

- (LupinusHTTPRequest *)LupinusRequest:(NSURLRequest *) request {
    // why dispatch_sync? https://github.com/Alamofire/Alamofire/issues/16
    __block NSURLSessionDataTask *dataTask;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dataTask = [self.session dataTaskWithRequest:request];
    });
    LupinusHTTPRequest *lupinHTTPRequest = [LupinusHTTPRequest requestWithSession:self.session dataTask:dataTask];
    self.delegateManager[dataTask] = lupinHTTPRequest;
    // start request
    [lupinHTTPRequest resume];
    return lupinHTTPRequest;
}

- (NSURLRequest *)urlRequest:(LupinusHTTPMethod) method URL:(NSString *) URLString query:(NSDictionary *) query {
    return [self requestWithMethod:[self NSStringFromLupinusHTTPMethod:method] path:URLString
                                                                               query:query body:nil];
}

- (NSURLRequest *)urlRequest:(LupinusHTTPMethod) method URL:(NSString *) URLString query:(NSDictionary *) query body:(id) body {
    return [self requestWithMethod:[self NSStringFromLupinusHTTPMethod:method] path:URLString
                                                                               query:query body:body];
}

- (NSURLRequest *)requestWithMethod:(NSString *) method path:(NSString *) URLString query:(NSDictionary *) query body:(id) body {
    NSAssert(URLString != nil, @"URLString is nil");
    NSAssert(![URLString isKindOfClass:[NSURL class]], @"URLString is a kind of NSURL");
    NSURL *url = [NSURL URLWithString:URLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:method];
    if (query) {
        url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:[URLString rangeOfString:@"?"].location == NSNotFound
                                                                                 ? @"?%@"
                                                                                 : @"&%@",
                                                                                 [URLQueryBuilder buildQueryWithDictionary:query]
        ]];
        [request setURL:url];
    }
    if (body) {
        NSError *error = nil;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
        [request setHTTPBody:postData];
        if (error) {
            NSLog(@"%@ %@: %@", [self class], NSStringFromSelector(_cmd), error);

        }
    }
    return request;
}

- (NSString *)NSStringFromLupinusHTTPMethod:(LupinusHTTPMethod) httpMethod {
    switch (httpMethod) {
        case LupinusMethodOPTIONS:
            return @"OPTIONS";
        case LupinusMethodGET:
            return @"GET";
        case LupinusMethodHEAD:
            return @"HEAD";
        case LupinusMethodPOST:
            return @"POST";
        case LupinusMethodPUT:
            return @"PUT";
        case LupinusMethodPATCH:
            return @"PATCH";
        case LupinusMethodDELETE:
            return @"DELETE";
        case LupinusMethodTRACE:
            return @"TRACE";
        case LupinusMethodCONNECT:
            return @"CONNECT";
    }
    return @"GET";// default
}

@end