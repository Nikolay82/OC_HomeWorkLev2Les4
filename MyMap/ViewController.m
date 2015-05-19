//
//  ViewController.m
//  MyMap
//
//  Created by Nikolay on 15.05.15.
//  Copyright (c) 2015 gng. All rights reserved.
//

#import "ViewController.h"
#import "SingleTone.h"

@interface ViewController ()
{
    BOOL isCurrentLocation;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) CLLocationManager * locationManager;


- (IBAction)nextView:(id)sender;

@end


@implementation ViewController

- (void)firstLunch {
    
    NSString * ver = [[UIDevice currentDevice] systemVersion];
    
    if ([ver integerValue] >= 8) {
        [self.locationManager requestAlwaysAuthorization];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstLunch"];
        
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isCurrentLocation = NO;
    self.mapView.showsUserLocation = YES;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    //[self.locationManager startUpdatingLocation];
    
    BOOL isFirstLunch = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstLunch"];
    if (!isFirstLunch) {
        [self firstLunch];
    }
    
    //SingleTone * sing =[SingleTone sharedSingleTone];
    //[sing makeMutableArray];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    SingleTone * sing =[SingleTone sharedSingleTone];

    if ([sing.someMArray count] > 0) {
        
        [self.mapView addAnnotations:sing.someMArray];
        
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MKMapViewDelegate

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    
    if (fullyRendered) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)setupMapView: (CLLocationCoordinate2D) coord {
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 5000, 5000);
    
    [self.mapView setRegion:region animated:YES];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if (![annotation isKindOfClass:MKUserLocation.class]) {
        
        MKAnnotationView * annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
        
        annView.canShowCallout = NO;
        annView.image = [UIImage imageNamed:@"marker.png"];
        
        return annView;
    }

    return nil;
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    //NSLog(@"locationManager - %f, %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    if (!isCurrentLocation) {
        isCurrentLocation = YES;
        
        [self setupMapView: newLocation.coordinate];
    }
}

#pragma mark -GestureRecognizer

- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"UIGestureRecognizerStateBegan");
        
        
        CLLocationCoordinate2D coordScreenPoint = [self.mapView convertPoint:[sender locationInView:self.mapView] toCoordinateFromView:self.mapView];
        
        CLGeocoder * geocoder = [[CLGeocoder alloc] init];
        
        CLLocation * tapLocation = [[CLLocation alloc] initWithLatitude:coordScreenPoint.latitude longitude:coordScreenPoint.longitude];
        
        [geocoder reverseGeocodeLocation:tapLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            
            CLPlacemark * place = [placemarks objectAtIndex:0];
            
            //NSLog(@"place %@", place.addressDictionary);
            
            NSString * addressString = [NSString stringWithFormat:@"Город - %@\nУлица - %@\nИндекс - %@",
                                        [place.addressDictionary valueForKey:@"City"],
                                        [place.addressDictionary valueForKey:@"Street"],
                                        [place.addressDictionary valueForKey:@"ZIP"]];
            
            /*
             UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Address" message:addressString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
             
             [alert show];
             */
            
            MKPointAnnotation * annotation = [[MKPointAnnotation alloc] init];
            annotation.title = addressString;
            annotation.coordinate = coordScreenPoint;

            SingleTone * sing =[SingleTone sharedSingleTone];
            //[sing.someMArray addObject:annotation];
            
            [sing addObjectToMArray:^id{
                return annotation;
            }];
                    
            [self.mapView addAnnotation:annotation];
            
        }];
        
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
       // NSLog(@"UIGestureRecognizerStateChanged");
        
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        //NSLog(@"UIGestureRecognizerStateEnded");
        
    }
}


- (IBAction)nextView:(id)sender {
    
    UIViewController * controllerTwo = [self.storyboard
                                        instantiateViewControllerWithIdentifier:@"ViewTwo"];
    
    [self.navigationController pushViewController:controllerTwo animated:YES];
    
}

@end
