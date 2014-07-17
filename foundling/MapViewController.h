//
//  MapViewController.h
//  ezsoundgltest
//
//  Created by Johann Diedrick on 1/29/14.
//  Copyright (c) 2014 Found Sound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface MapViewController : UIViewController <MKMapViewDelegate, AudioPlayerDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UIButton* refreshButton;

//audio player
@property (strong, atomic) AVAudioSession *audioSession;
@property (strong, nonatomic) AVPlayer* audioPlayer;
@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;

@end
