//
// Created by azu on 2014/08/20.
//


#import <Foundation/Foundation.h>


@interface LupinusHTTPSessionTaskDelegate : NSObject <NSURLSessionDelegate>
- (id)objectForKeyedSubscript:(NSURLSessionTask *) task;

- (void)setObject:(id <NSURLSessionDataDelegate>) object forKeyedSubscript:(NSURLSessionTask *) task;
@end