//
//  MapViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/14/21.
//

#import "MapViewController.h"
#import "APIManager.h"
@import MapKit;
@import CoreLocation;

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation MapViewController

const int STORE_COUNT = 5;
const int MAX_MILES = 10;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.locationManager.delegate = self;
    [self getUserLocation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    // If no pin view already exists, create a new one.
    if (annotation == self.mapView.userLocation) {
        self.mapView.showsUserLocation = YES;
        return nil; // default - blue, pulsing dot
    } else {
        MKPinAnnotationView *customPinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
        if (customPinView == nil) {
            customPinView = [[MKPinAnnotationView alloc]
                             initWithAnnotation:annotation reuseIdentifier:@"Pin"];
            customPinView.pinTintColor = UIColor.redColor;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
        }
        UILabel *subTitlelbl = [[UILabel alloc]init];
        subTitlelbl.text = annotation.subtitle;
        subTitlelbl.textColor = UIColor.grayColor;
        
        customPinView.detailCalloutAccessoryView = subTitlelbl;
        
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:subTitlelbl attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:200];
        
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:subTitlelbl attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
        [subTitlelbl setNumberOfLines:0];
        [subTitlelbl addConstraint:width];
        [subTitlelbl addConstraint:height];
        
        return customPinView;
    }
}

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager{
    if (manager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    if (locations.firstObject) {
        MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
        MKCoordinateRegion region = MKCoordinateRegionMake(locations.firstObject.coordinate, span);
        [self.mapView setRegion:region];
        CLLocation* userLocation = locations.firstObject;
        
        // [self searchForNearbyPharamacies];
        [self searchForWalgreens:userLocation];
    }
}

-(void) getUserLocation{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = 200;
    [self.locationManager requestWhenInUseAuthorization];
}

- (IBAction)didTapBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) searchForWalgreens:(CLLocation*) userLocation {
    NSMutableDictionary* locationInformation = [[NSMutableDictionary alloc] init];
    float latitudeFloat = (float) userLocation.coordinate.latitude;
    float longitudeFloat = (float) userLocation.coordinate.longitude;
    
    [locationInformation addEntriesFromDictionary:@{@"lat": [NSNumber numberWithFloat: latitudeFloat]}];
    [locationInformation addEntriesFromDictionary:@{@"lng": [NSNumber numberWithFloat: longitudeFloat]}];
    [locationInformation addEntriesFromDictionary:@{@"r": [NSNumber numberWithInt:MAX_MILES]}];
    [locationInformation addEntriesFromDictionary:@{@"s": [NSNumber numberWithInt:STORE_COUNT]}];
    
    [[APIManager shared] getNearbyWalgreens:locationInformation completion:^(NSDictionary * _Nonnull results, NSError * _Nonnull error) {
        NSDictionary* storeResults = results[@"results"];
        NSMutableArray *placemarks = [NSMutableArray array];
        for (NSDictionary *store in storeResults) {
            CLLocationDegrees latitude = [store[@"latitude"] doubleValue];
            CLLocationDegrees longitude = [store[@"longitude"] doubleValue];
            
            NSDictionary *storeInformation = store[@"store"];
            NSDictionary *phoneInformation = storeInformation[@"phone"];
            NSDictionary *addressInformation = storeInformation[@"address"];
            
            NSString *phoneNumber = [NSString stringWithFormat:@"%@-%@-%@", phoneInformation[@"areaCode"] , [phoneInformation[@"number"] substringToIndex:3], [phoneInformation[@"number"] substringFromIndex:3]];
            NSString* address = [NSString stringWithFormat:@"%@\n%@\n%@, %@", addressInformation[@"street"], addressInformation[@"city"], addressInformation[@"state"], addressInformation[@"zip"]];
            
            NSString* title = storeInformation[@"name"];
            NSString* subtitle = [NSString stringWithFormat:@"%@\n%@\nHours:%@-%@",
                                  [address capitalizedString],
                                  phoneNumber,
                                  storeInformation[@"pharmacyOpenTime"],
                                  storeInformation[@"pharmacyCloseTime"]];
            
            CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] initWithCoordinate:location title:title subtitle:subtitle];
            [placemarks addObject:annotation];
        }
        [self.mapView showAnnotations:placemarks animated:YES];
    }];
}

-(void) searchForNearbyPharamacies{
    // Create and initialize a search request object.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = @"Walgreens";
    self.navigationItem.title = @"Search for Walgreens";
    request.region = self.mapView.region;
    
    // Create and initialize a search object.
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    // Start the search and display the results as annotations on the map.
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
     {
        int limit = 5;
        NSMutableArray *placemarks = [NSMutableArray array];
        if (response.mapItems.count < 5) {
            limit = response.mapItems.count;
        }
        
        for (int i = 0; i < limit; i++) {
            MKMapItem *item = response.mapItems[i];
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] initWithCoordinate:item.placemark.coordinate title:item.name subtitle:item.phoneNumber];
            [placemarks addObject:annotation];
            
        }
        
        MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
        MKCoordinateRegion region = MKCoordinateRegionMake(self.mapView.centerCoordinate, span);
        self.mapView.region = region;
        
        [self.mapView removeAnnotations:[self.mapView annotations]];
        [self.mapView showAnnotations:placemarks animated:YES];
    }];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
