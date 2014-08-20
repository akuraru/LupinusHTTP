//
// Created by azu on 2014/08/20.
//


#import "LupinusHTTPSessionTaskDelegate.h"


@interface LupinusHTTPSessionTaskDelegate ()
@property(nonatomic, strong) NSMutableDictionary *delegateMapping;
@end

@implementation LupinusHTTPSessionTaskDelegate {

}
- (id)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _delegateMapping = [NSMutableDictionary dictionary];

    return self;
}

#pragma mark - Subscript

// delegateManager[task] = delegate
- (id)objectForKeyedSubscript:(NSURLSessionTask *) task {
    return self.delegateMapping[@(task.taskIdentifier)];
}

- (void)setObject:(id <NSURLSessionDataDelegate>) object forKeyedSubscript:(NSURLSessionTask *) task {
    self.delegateMapping[@(task.taskIdentifier)] = object;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *) session dataTask:(NSURLSessionDataTask *) dataTask didReceiveData:(NSData *) data {
    id <NSURLSessionDataDelegate> delegate = self[dataTask];
    if ([delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)]) {
        [delegate URLSession:session dataTask:dataTask didReceiveData:data];
    }
}

- (void)URLSession:(NSURLSession *) session task:(NSURLSessionTask *) task didCompleteWithError:(NSError *) error {
    id <NSURLSessionDataDelegate> delegate = self[task];
    if ([delegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
        [delegate URLSession:session task:task didCompleteWithError:error];
    }
}
@end