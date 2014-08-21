//
// Created by azu on 2014/08/19.
//


#import "LupinusHTTPRequest.h"


@interface LupinusHTTPRequest ()
@property(nonatomic, strong) NSURLRequest *request;
@property(nonatomic, strong) NSURLSessionDataTask *dataTask;
@property(nonatomic, strong) NSError *response_error;
@property(nonatomic, strong) NSData *response_data;
@property(nonatomic, strong) dispatch_queue_t queue;
@end

@implementation LupinusHTTPRequest {

}
- (instancetype)initWithSession:(NSURLSession *) session dataTask:(NSURLSessionDataTask *) dataTask {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.dataTask = dataTask;
    // create queue and default status is stop!
    NSString *queueLabel = [NSString stringWithFormat:@"info.efcl.LupinusHTTP.task-%d", dataTask.taskIdentifier];
    dispatch_queue_t queue = dispatch_queue_create(queueLabel.UTF8String, DISPATCH_QUEUE_SERIAL);
    dispatch_suspend(queue);
    self.queue = queue;
    return self;
}

+ (instancetype)requestWithSession:(NSURLSession *) session dataTask:(NSURLSessionDataTask *) dataTask {
    return [[self alloc] initWithSession:session dataTask:dataTask];
}

- (void)resume {
    [self.dataTask resume];
}

- (void)cancel {
    [self.dataTask cancel];
}

// response is always async callback
- (void)responseJSON:(LupinusHTTPRequestResponseJSON) complete {
    dispatch_async(self.queue, ^{
        if (self.response_error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(self.request, self.dataTask.response, nil, self.response_error);
            });
        } else {
            NSError *jsonError = nil;
            id JSON = [NSJSONSerialization JSONObjectWithData:self.response_data options:0 error:&jsonError];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (jsonError) {
                    complete(self.request, self.dataTask.response, JSON, jsonError);
                } else {
                    complete(self.request, self.dataTask.response, JSON, self.response_error);
                }
            });
        }
    });
}

- (void)responseString:(LupinusHTTPRequestResponseString) complete {
    dispatch_async(self.queue, ^{
        if (self.response_error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(self.request, self.dataTask.response, nil, self.response_error);
            });
        } else {
            NSString *string = [[NSString alloc] initWithData:self.response_data encoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(self.request, self.dataTask.response, string, self.response_error);
            });
        }
    });
}

- (void)responseRawData:(LupinusHTTPRequestResponseRawData) complete {
    dispatch_async(self.queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(self.request, self.dataTask.response, self.response_data, self.response_error);
        });
    });
}

#pragma mark  - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *) session dataTask:(NSURLSessionDataTask *) dataTask didReceiveData:(NSData *) data {
    self.response_data = data;
}

// always call this method when success or failure.
- (void)URLSession:(NSURLSession *) session task:(NSURLSessionTask *) task didCompleteWithError:(NSError *) error {
    // prevent app leaks memory
    // 15. https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/URLLoadingSystem/NSURLSessionConcepts/NSURLSessionConcepts.html
    [session invalidateAndCancel];

    // if request is canceled, then doesn't resume queue.
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    self.response_error = error;
    // resume -> start response*handler
    dispatch_resume(self.queue);

}


@end