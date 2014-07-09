//
//  SecondViewController.h
//  ezsoundgltest
//
//  Created by Johann Diedrick on 1/29/14.
//  Copyright (c) 2014 Found Sound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AudioPlayer.h"

@interface SecondViewController : UIViewController <MKMapViewDelegate, AudioPlayerDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, atomic) NSMutableArray *audioPlayers;

@end
