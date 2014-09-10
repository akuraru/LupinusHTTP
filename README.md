# LupinusHTTP

![Lupinus](http://monosnap.com/image/pg8v9Wa1IkBbjB9jUioE0YABMe8C41.png)

[![CI Status](http://img.shields.io/travis/azu/LupinusHTTP.svg?style=flat)](https://travis-ci.org/azu/LupinusHTTP)
[![Version](https://img.shields.io/cocoapods/v/LupinusHTTP.svg?style=flat)](http://cocoadocs.org/docsets/LupinusHTTP)
[![License](https://img.shields.io/cocoapods/l/LupinusHTTP.svg?style=flat)](http://cocoadocs.org/docsets/LupinusHTTP)
[![Platform](https://img.shields.io/cocoapods/p/LupinusHTTP.svg?style=flat)](http://cocoadocs.org/docsets/LupinusHTTP)

LupinusHTTP is an HTTP networking library, wrapping `NSURLSession`.

## Feature

- Small, Simple
- Block-based response methods.

## Installation

LupinusHTTP is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "LupinusHTTP"

## Usage

LupinusHTTP has very simple step to request.

1. Create `LupinusHTTPRequest` through `LupinusHTTP`'s method.
    * HTTP Method and URL and Parameters and (post body).
2. Receive response using `responseJSON` or `responseString` methods.


### GET Request

Example: Get Request to http://httpbin.org/get?key=value

```objc
LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get" query:@{
    @"key" : @"value"
}];
[httpRequest responseJSON:^(NSURLRequest *request, NSURLResponse *response, id JSON, NSError *error) {
    NSLog(@"JSON = %@", JSON);
}];
```

#### Get response as JSON

Always `response*` complete method involked in matin thread.

```objc
LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get"];
[httpRequest responseJSON:^(NSURLRequest *request, NSURLResponse *response, id JSON, NSError *error) {
    NSLog(@"JSON = %@", JSON);// => JSON Object(NSDictionary or NSArray)
}];
```

#### Get response as String

```objc
LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get"];
[httpRequest responseString:^(NSURLRequest *request, NSURLResponse *response, NSString *string, NSError *error) {
    NSLog(@"string = %@", string);// => NSString
}];
```


#### Get response as RawData

```objc
LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get"];
[httpRequest responseRawData:^(NSURLRequest *request, NSURLResponse *response, NSData *data, NSError *error) {
    // data
}];
```

### POST Request

#### Post Request with body

    e.g) http://httpbin.org/post?key=value

    body
        [1,2,3]


```objc
[LupinusHTTP request:LupinusMethodPOST URL:@"http://httpbin.org/post" query:@{
    @"key" : @"value"
} body:@[@1, @2, @3]];
[httpRequest responseJSON:^(NSURLRequest *request, NSURLResponse *response, id JSON, NSError *error) {
    NSLog(@"JSON = %@", JSON);// => JSON Object(NSDictionary or NSArray)
}];
```

### Common behavior - response.statusCode >= 400

When response.statusCode >= 400, recognize request as failed and `error` is filled by  status code of.

```objc
LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/status/403"];
// response status code is 403
[httpRequest responseJSON:^(NSURLRequest *request, NSURLResponse *response, id JSON, NSError *error) {
    // error is not nil
    if(error){
        NSLog(@"%@", error);
    }
}];
```

### Use Custom NSURLSession

You can create a new session with a modified session configuration.

```objc
// default : [NSURLSessionConfiguration defaultSessionConfiguration]
+ (instancetype)httpWithSessionConfiguration:(NSURLSessionConfiguration *) sessionConfiguration;
```

### Cancel Request

You can cancel the request by `LupinusHTTPRequest#cancel`.

```objc
LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get"];
[httpRequest responseJSON:^(NSURLRequest *request, NSURLResponse *response, id JSON, NSError *error) {
  // this callback doens't call!
}];
// cancel request
[httpRequest cancel];
```

## LupinusHTTP Request Flow

Request flow design of LupinusHTTP.

```objc
// Create NSURLSession and NSURLRequest.
LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get"];
// already started HTTP request
// ...
// you can register complete handler
// Lupinus add this handler to `queue`
[httpRequest responseJSON:^(NSURLRequest *request, NSURLResponse *response, id JSON, NSError *error) {
    NSLog(@"JSON = %@", JSON);// => JSON Object(NSDictionary or NSArray)
}];

// ....
// Get HTTP response.
// Lupinus dispatch_resume(self.queue); => callback the complete handlers.
```

## FAQ

### Does LupinusHTTP work with Background Fetch?

No.

LupinusHTTP doens't work with Background Fetch.

- [Multitasking in iOS 7 - iOS 7 - objc.io issue #5](http://www.objc.io/issue-5/multitasking.html "Multitasking in iOS 7 - iOS 7 - objc.io issue #5")
- Background Fetch require using `NSURLSessionDownloadTask`.

But, welcome to your pull request!


## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D


## License

LupinusHTTP is available under the MIT license. See the LICENSE file for more info.

## Acknowledgment

LupinusHTTP inspired by [Alamofire](https://github.com/Alamofire/Alamofire "Alamofire"), [AFNetworking](https://github.com/AFNetworking/AFNetworking "AFNetworking") and [TacoShell](https://github.com/BurritoKit/TacoShell "TacoShell").

## Credit

Photo by <a href="http://500px.com/photo/76029573" target="_blank">Tatu Väyrynen</a>
