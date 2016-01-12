//
//  ViewController.m
//  StationFinderRevised
//
//  Created by Charles Grier on 10/14/15.
//  Copyright © 2015 Grier Mobile Development. All rights reserved.
//

#import "ViewController.h"
#import "Mapbox/Mapbox.h"
#import "Station.h"
#import "WebViewController.h"
#import "StationDotsView.h"

@interface ViewController () <MGLMapViewDelegate>

@property (nonatomic, strong) MGLMapView *mapView;
@property (nonatomic, strong) NSMutableSet *selectedLines;
@property (nonatomic, strong) NSMutableSet *stationAnnotations;

@end

@implementation ViewController

#warning -- Enter your Mapbox Access Token in Info.plist

- (void)viewDidLoad {
    [super viewDidLoad];
   
    //  set style to Emerald and initizalize Mapbox mapview and
    self.mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds styleURL:[MGLStyle emeraldStyleURL]];
    
    //self.mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // set the map's center coordinate
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(38.910003, -77.015533)
                            zoomLevel:9
                             animated:NO];
    
    // add the map to your view
    [self.view addSubview:self.mapView];
    
    // set delegate property for the map view to self
    self.mapView.delegate = self;
    
    // Declare the annotation `point` and set its coordinates, title, and subtitle
    MGLPointAnnotation *point = [[MGLPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(38.894368, -77.036487);
    point.title = @"Hello world!";
    point.subtitle = @"Welcome to The Ellipse.";
    
    // Add annotation `point` to the map
    [self.mapView addAnnotation:point];
    
    // create an array of lines
    self.selectedLines = [[NSMutableSet alloc] initWithArray:@[@"Blue", @"Green", @"Orange", @"Red", @"Silver", @"Yellow"]];
    
    // instaniate stationAnnotations set so we can start adding markers to it as they are created
    self.stationAnnotations = [[NSMutableSet alloc] init];
    
    //self.stationAnnotations = [[NSMutableSet alloc] initWithArray:@[@"Blue"]];
    
    [self loadStations];
    
}

// to use default marker, return nil
- (MGLAnnotationImage *) mapView:(MGLMapView *)mapView imageForAnnotation:(id<MGLAnnotation>)annotation
{
    
    UIImage *image = [UIImage imageNamed:@"rail-metro-blue"];
    NSString *reuseIdentifier = @"station";
    
    MGLAnnotationImage *annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:reuseIdentifier];
    
    return annotationImage;
}

// Show a callout when an annotation is tapped.
- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id <MGLAnnotation>)annotation
{
    return YES;
}

-(UIView *)mapView:(MGLMapView *)mapView rightCalloutAccessoryViewForAnnotation:(id<MGLAnnotation>)annotation
{
    UIButton *rightCallout = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return rightCallout;
}

// create left callout for station color information
- (nullable UIView *)mapView:(MGLMapView *)mapView leftCalloutAccessoryViewForAnnotation:(id <MGLAnnotation>)annotation
{
    Station *selectedStation = (Station *)annotation;
    NSSet *lines = selectedStation.lines;
    StationDotsView *dots = [[StationDotsView alloc] initWithLines:lines];
    
    return dots;
}


-(void)mapView:(MGLMapView *)mapView annotation:(id<MGLAnnotation>)annotation calloutAccessoryControlTapped:(UIControl *)control
{
    Station *selectedStation = (Station *)annotation;
    NSLog(@"Custom CALLOUT TAPPED %@", selectedStation.url);
    
    // instaniate a new WebViewController
    WebViewController *webVC = [[WebViewController alloc]init];
    webVC.stationURL = [NSURL URLWithString:selectedStation.url];
    webVC.title = [NSString stringWithFormat:@"Arrivals"];
    
    // assign the WebViewController to a navigation controller
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
    nav.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:nav animated:YES completion:nil];
    
    // Get the modal popover presentation controller and configure it.
    UIPopoverPresentationController *presentationController = [nav popoverPresentationController];
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
    presentationController.sourceView = self.mapView;

}

# pragma mark -- Load the stations from the local geojson file
-(void)loadStations
{
    
    // Put the JSON parsing code in here
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"stations" ofType:@"geojson"];
    
    // make sure if you can load the geojson file
    if (![[NSFileManager defaultManager] fileExistsAtPath:jsonPath]) {
        NSLog(@"Error! Cound not find the station.geojson file.");
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSError *error = nil;
    
    // Deserialize the GeoJSON
    NSDictionary *jsonDict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    // Parse the GeoJSON code on a background thread
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^(void)
    {
        
    // assign the jsonDict[@"features"] array to a NSArray called stationFeatures
    NSArray *stationFeatures = jsonDict[@"features"];

    //NSLog(@"%@", stationFeatures);
    
    // Each element of the array is going to be an NSDictionary, so iterate over the array
    for (NSDictionary *feature in stationFeatures)
    {
        // point features
        if ([feature[@"geometry"][@"type"] isEqualToString:@"Point"]) {
            
            // create CLLocationCoordinate2D with lat long values
            CLLocationCoordinate2D coordinate = {
                .longitude = [feature[@"geometry"][@"coordinates"][0] floatValue],
                .latitude  = [feature[@"geometry"][@"coordinates"][1] floatValue]
            };
            
            // assign properties to a NSDictionary
            NSDictionary *properties = feature[@"properties"];
            
            //create a new station object and coordinates, title, and line for use in annotations
            Station *stationAnnotation = [[Station alloc]init];
            stationAnnotation.url = properties[@"url"];
            stationAnnotation.title = properties[@"title"];
            stationAnnotation.coordinate = coordinate;
            stationAnnotation.lines = properties[@"lines"];
            
            // stations can have multiple lines
            NSString *result = [properties[@"lines"] componentsJoinedByString:@" / "];
            stationAnnotation.subtitle = result;
            
            stationAnnotation.userInfo = properties;
            
            // add to our array
            [self.stationAnnotations addObject:stationAnnotation];
            
            // add annotations on main thread since it is dealing with UI
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                // add annotations to the map view
                [self.mapView addAnnotation:stationAnnotation];
            });
        }
        }
    });

}

- (BOOL)annotationShouldBeHidden:(Station *)annotation
{
    NSSet *stationLineColors = [NSSet setWithArray:annotation.userInfo[@"lines"]];
    BOOL doesIntersect = [stationLineColors intersectsSet:self.selectedLines];
    return !doesIntersect;
}



@end
