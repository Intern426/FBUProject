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
#import "OAuth2/OAuthRequestController.h"

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

+ (instancetype) sharedSquare {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] initWithSquare];
    });
    return sharedManager;
}




- (instancetype) initWithSquare{
    
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    
    // Pull API Keys from your new Keys.plist file
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Key" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    
    
    
    self = [super initWithBaseURL:baseURL];
    if (self) {
        
    }
    return self;
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

/*- (void)postOrderWithCompletion:(NSString *)text completion:(void (^)(Order *, NSError *))completion{
    NSDictionary *parameters = @{@"location_id": text};
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable orders) {
        completion(nil, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}*/

@end
