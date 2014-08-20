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

1. Create LupinusHTTPRequest
    * HTTP Method and URL and Parameters and (post body).
2. Receive response object using `responseJSON` or `responseString` methods.


### GET Request

Example: Get Request to http://httpbin.org/get?key=value

```objc
LupinusHTTPRequest *httpRequest = [LupinusHTTP request:LupinusMethodGET URL:@"http://httpbin.org/get" query:@{
    @"key" : @"value"
}];
[httpRequest responseJSON:^(NSURLRequest *request, NSURLResponse *response, id JSON, NSError *error) {
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

```objc
[LupinusHTTP request:LupinusMethodPOST URL:@"http://httpbin.org/post" query:@{
    @"key" : @"value"
} body:@[@1, @2, @3]];
[httpRequest responseJSON:^(NSURLRequest *request, NSURLResponse *response, id JSON, NSError *error) {
    NSLog(@"JSON = %@", JSON);// => JSON Object(NSDictionary or NSArray)
}];
```

## Author

azu, azuciao@gmail.com

## License

LupinusHTTP is available under the MIT license. See the LICENSE file for more info.

## Acknowledgment

LupinusHTTP inspired by [Alamofire](https://github.com/Alamofire/Alamofire "Alamofire").

## Credit

Photo by <a href="http://500px.com/photo/76029573" target="_blank">Tatu Väyrynen</a>