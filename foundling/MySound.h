//
//  MySound.h
//  MapKitTutorial
//
//  Created by Johann Diedrick on 8/15/13.
//  Copyright (c) 2013 Johann Diedrick. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MySound : NSObject

- (id)initWithName:(NSString*)name sound_url:(NSString*)sound_url coordinate:(CLLocationCoordinate2D)coordinate;
- (MKMapItem*)mapItem;

@end
