//
//  APIManager.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/20/21.
//

#import "APIManager.h"
#import "Prescription.h"

@implementation APIManager

#warning move this to a Keys file!
NSString *apiKey = @"";


+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

/*
 * Analogy:
 * Synchronous Call - I call you to do something, you tell me to do something and wait five minutes while on the call
 * Aynsynchronous call - I call you to do something, you hang up and return teh data when you're done while I'm doing something else
 */

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

@end
