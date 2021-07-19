//
//  MapViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/14/21.
//

#import "MapViewController.h"
@import MapKit;
@import CoreLocation;

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    [self getUserLocation];
    
    // Do any additional setup after loading the view.
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    // If no pin view already exists, create a new one.
    if (annotation == self.mapView.userLocation) {
        self.mapView.showsUserLocation = YES;
        return nil;
    } else {
        MKPinAnnotationView *customPinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
        if (customPinView == nil) {
            customPinView = [[MKPinAnnotationView alloc]
                             initWithAnnotation:annotation reuseIdentifier:@"Pin"];
            customPinView.pinTintColor = UIColor.purpleColor;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
        }
        
        // Because this is an iOS app, add the detail disclosure button to display details about the annotation in another view.
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        customPinView.rightCalloutAccessoryView = rightButton;
        
        // Add a custom image to the left side of the callout.
        UIImageView *myCustomImage = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"star"]];
        customPinView.leftCalloutAccessoryView = myCustomImage;
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
        [self searchForNearbyPharamacies];
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
