//
//  ViewController.m
//  StationFinderRevised
//
//  Created by Charles Grier on 10/14/15.
//  Copyright © 2015 Grier Mobile Development. All rights reserved.
//

#import "ViewController.h"
#import "Mapbox.h"

@interface ViewController () <MGLMapViewDelegate>

@property (nonatomic, strong) MGLMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    //  set style to Emerald and initizalize Mapbox mapview and
    NSURL *styleURL = [NSURL URLWithString:@"asset://styles/emerald-v8.json"];
    self.mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds styleURL:styleURL];
    
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
    
}

// Show a callout when an annotation is tapped.
- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id <MGLAnnotation>)annotation
{
    return YES;
}

@end
