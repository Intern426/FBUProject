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

-(void) getDrugInformationRxNorm:(NSString *)drugName completion:(void (^)(NSDictionary * information, NSError * error))completion{
    drugName = [drugName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *urlString = [NSString stringWithFormat:@"https://rxnav.nlm.nih.gov/REST/drugs.json?name=%@", drugName];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            completion(nil, error);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            completion(dataDictionary, nil);
        }
    }];
    [task resume];
}

-(void) getDrugInformationOpenFDABrandName:(NSString*) drugName completion: (void (^)(NSDictionary * information, NSError * error))completion{
    drugName = [drugName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *urlString = [NSString stringWithFormat:@"https://api.fda.gov/drug/label.json?search=openfda.brand_name.exact:%@", [drugName uppercaseString]];
    NSLog(@"%@", urlString);
    NSURL *url = [NSURL URLWithString:urlString]; // openFDA search queries are case sensitive
    
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            completion(nil, error);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            completion(dataDictionary, nil);
        }
    }];
    [task resume];
}

-(void) getDrugInformationOpenFDAGenericName:(NSString*) drugName completion: (void (^)(NSDictionary * information, NSError * error))completion{
    drugName = [drugName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *urlString = [NSString stringWithFormat:@"https://api.fda.gov/drug/label.json?search=openfda.generic_name.exact:%@", [drugName uppercaseString]];
    NSLog(@"%@", urlString);
    NSURL *url = [NSURL URLWithString:urlString]; // openFDA search queries are case sensitive
    
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            completion(nil, error);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            completion(dataDictionary, nil);
        }
    }];
    [task resume];
}

-(void) getDrugInformationOpenFdaUsingRxcui:(NSString *)rxcui completion:(void (^)(NSDictionary * _Nonnull, NSError * _Nonnull))completion{
    rxcui = [rxcui stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *urlString = [NSString stringWithFormat:@"https://api.fda.gov/drug/label.json?search=openfda.rxcui:%@", rxcui];
    NSLog(@"%@", urlString);
    NSURL *url = [NSURL URLWithString:urlString]; // openFDA search queries are case sensitive
    
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            completion(nil, error);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            completion(dataDictionary, nil);
        }
    }];
    [task resume];
}


- (void) uploadPaymentWithCompletion: (NSMutableDictionary*) parameters completion:  (void (^)(NSDictionary * payment, NSError * error))completion{
    NSString *string = [[[NSProcessInfo processInfo] globallyUniqueString] substringWithRange:NSMakeRange(0, 44)];
    [parameters addEntriesFromDictionary:@{@"idempotency_key": string}];
    
    NSData *jsonItem = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingSortedKeys error:nil];
    
    NSMutableURLRequest *request = [self setupURLRequestSquare:@"v2/payments"];
    
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
    NSData *jsonItem = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingSortedKeys error:nil];
    NSMutableURLRequest *request = [self setupURLRequestSquare:@"v2/orders"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionTask *task = [session uploadTaskWithRequest:request fromData:jsonItem completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
            completion(nil, error);
        }
        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        completion(dataDictionary, nil);
    }];
    [task resume];
    
}

- (NSMutableURLRequest*) setupURLRequestSquare: (NSString*) url{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Key" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    
    NSMutableString *baseURL = [[NSMutableString alloc] initWithString:@"https://connect.squareupsandbox.com/"];
    [baseURL appendString:url];
    
    NSURL *sendingUrl = [NSURL URLWithString:baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:sendingUrl];
    
    // Add the required keys for any call to Square
    request.HTTPMethod = @"POST";
    [request addValue:@"2021-07-21"  forHTTPHeaderField:@"Square-Version"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *authorization = [NSString stringWithFormat:@"Bearer %@", [dict objectForKey: @"square_access_token"]];
    [request addValue:authorization forHTTPHeaderField:@"Authorization"];
    return request;
}

- (void) getNearbyWalgreens: (NSMutableDictionary*) locationInfo completion:  (void (^)(NSDictionary * stores, NSError * error))completion{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Key" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    
    NSURL* url = [NSURL URLWithString:@"https://services-qa.walgreens.com/api/stores/search/v2"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    request.HTTPMethod = @"POST";
    
    [locationInfo addEntriesFromDictionary:@{@"apiKey": [dict objectForKey:@"walgreens_api_key"]}];
    [locationInfo addEntriesFromDictionary:@{@"affId": [dict objectForKey:@"store_finder_affiliate"]}];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"data": locationInfo}];
    
    NSData *jsonItem = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingSortedKeys error:nil];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionTask *task = [session uploadTaskWithRequest:request fromData:jsonItem completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
            completion(nil, error);
        }
        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        completion(dataDictionary, nil);
    }];
    [task resume];
}

@end
