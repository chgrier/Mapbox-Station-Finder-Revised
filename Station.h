//
//  Station.h
//  StationFinderRevised
//
//  Created by Charles Grier on 10/14/15.
//  Copyright © 2015 Grier Mobile Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mapbox.h"

@interface Station : NSObject <MGLAnnotation>

// properties for annotation popup
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

// other properties stored as annotations
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSSet *lines;

// to store user data for later
@property (nonatomic, strong) id userInfo;

@end
