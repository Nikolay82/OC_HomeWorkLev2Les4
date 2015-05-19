//
//  ViewControllerTwo.m
//  MyMap
//
//  Created by Nikolay on 18.05.15.
//  Copyright (c) 2015 gng. All rights reserved.
//

#import "ViewControllerTwo.h"
#import "SingleTone.h"

@interface ViewControllerTwo ()
{
    BOOL isCurrentLocation;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) CLLocationManager * locationManager;

@property (strong, nonatomic) IBOutlet UITableView *tableAnnotations;


- (IBAction)buttonClearPressed:(id)sender;

@end

@implementation ViewControllerTwo

- (void)viewDidLoad {
    [super viewDidLoad];

    isCurrentLocation = NO;
    self.mapView.showsUserLocation = YES;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    //[self.locationManager startUpdatingLocation];
    
    SingleTone * sing =[SingleTone sharedSingleTone];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.tableAnnotations reloadData];

    if ([sing.someMArray count] > 0) {
            
        [self.mapView addAnnotations:sing.someMArray];
            
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)buttonClearPressed:(id)sender {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    SingleTone * sing =[SingleTone sharedSingleTone];
    [sing.someMArray removeAllObjects];
    
    [self.tableAnnotations reloadData];
    
}



#pragma mark - UITableViewDelegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    SingleTone * sing =[SingleTone sharedSingleTone];
    return [sing.someMArray count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * cellIdentifier = @"Cell";
    
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    //    if (cell == nil) {
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    //    }
    
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    
    UILabel * label = [[UILabel alloc] initWithFrame: CGRectMake(10, 0, cell.frame.size.width, cell.frame.size.height)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:12];
    
    SingleTone * sing =[SingleTone sharedSingleTone];
    MKPointAnnotation * annotation = [sing.someMArray objectAtIndex:indexPath.row];
    label.text = annotation.title;
    
    [cell addSubview:label];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"didHighlightRowAtIndexPath - %d", indexPath.row);
    
    SingleTone * sing =[SingleTone sharedSingleTone];
    MKPointAnnotation * annotation = [sing.someMArray objectAtIndex:indexPath.row];
    
    [self setupMapView: annotation.coordinate];

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
        
        [annView addSubview:[self getCalloutView:annotation.title]];
        
        return annView;
    }
    
    return nil;
}

- (UIView *)getCalloutView: (NSString *) title {
    
    UIView * callView = [[UIView alloc] initWithFrame:CGRectMake(-90, -90, 200, 80)];
    callView.backgroundColor = [UIColor whiteColor];
    callView.tag = 1000;
    callView.alpha = 0;
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 190, 70)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:12];
    label.text = title;
    
    [callView addSubview:label];
    
    return callView;
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if (![view.annotation isKindOfClass:MKUserLocation.class]) {
        
        for (UIView * subView in view.subviews) {
            
            if (subView.tag == 1000) {
                
                [self setupMapView: view.annotation.coordinate];
                
                subView.alpha = 1;
                
            }
            
        }
    }
    
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    for (UIView * subView in view.subviews) {
        
        if (subView.tag == 1000) {
            subView.alpha = 0;
        }
        
    }
    
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




@end
