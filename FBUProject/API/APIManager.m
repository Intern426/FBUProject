//
//  APIManager.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/20/21.
//

#import "APIManager.h"
#import "Prescription.h"
#import "Order.h"

#import "Parse/Parse.h"
@import SquareInAppPaymentsSDK;

@implementation APIManager

static NSString * const baseURLString = @"https://connect.squareupsandbox.com";

+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}


- (void)getDrugsWithCompletion:(void (^)(NSArray *, NSError *))completion{
    // get the data from the user's endpoint
    NSURL *url = [NSURL URLWithString:@"https://api.fda.gov/drug/drugsfda.json?count=products.brand_name.exact&limit=10"];
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            completion(nil, error);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *drugResults = dataDictionary[@"results"];
            NSMutableArray *prescriptions  = [Prescription prescriptionsWithArray:drugResults];
            completion(prescriptions, nil);
        }
    }];
    [task resume];
}

- (void) uploadPaymentWithCompletion: (NSMutableDictionary*) parameters completion:  (void (^)(NSDictionary * payment, NSError * error))completion{
    NSString *string = [[[NSProcessInfo processInfo] globallyUniqueString] substringWithRange:NSMakeRange(0, 44)];
    [parameters addEntriesFromDictionary:@{@"idempotency_key": string}];
    
    NSData *jsonItem = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingSortedKeys error:nil];
    
    NSMutableURLRequest *request = [self setupURLRequest:@"v2/payments"];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionTask *task = [session uploadTaskWithRequest:request fromData:jsonItem completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) { // Something wrong with the authentication/url session
            NSLog(@"%@", error.localizedDescription);
            completion(nil, error);
        }
        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        completion(dataDictionary, nil);
    }];
    [task resume];
}

- (void) uploadOrderWithCompletion: (NSMutableDictionary*) parameters completion:  (void (^)(NSDictionary * order, NSError * error))completion{
    NSString *string = [[[NSProcessInfo processInfo] globallyUniqueString] substringWithRange:NSMakeRange(0, 44)];
    [parameters addEntriesFromDictionary:@{@"idempotency_key": string}];
    
}


- (NSMutableURLRequest*) setupURLRequest: (NSString*) url{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Key" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    
    NSMutableString *baseURL = [[NSMutableString alloc] initWithString:@"https://connect.squareupsandbox.com/"];
    
    [baseURL appendString:url];
    
    NSURL *sendingUrl = [NSURL URLWithString:baseURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:sendingUrl];
    
    request.HTTPMethod = @"POST";
    [request addValue:@"2021-07-21"  forHTTPHeaderField:@"Square-Version"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *authorization = [NSString stringWithFormat:@"Bearer %@", [dict objectForKey: @"square_access_token"]];
    [request addValue:authorization forHTTPHeaderField:@"Authorization"];
    return request;
}

@end
