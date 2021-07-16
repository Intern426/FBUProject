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
    // Do any additional setup after loading the view.
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
        NSMutableArray *placemarks = [NSMutableArray array];
        for (MKMapItem *item in response.mapItems) {
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    // If no pin view already exists, create a new one.
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



-(void) getUserLocation{
    
}

- (IBAction)didTapBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
