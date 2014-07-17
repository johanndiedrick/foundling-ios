//
//  MapViewController.m
//  ezsoundgltest
//
//  Created by Johann Diedrick on 1/29/14.
//  Copyright (c) 2014 Found Sound. All rights reserved.
//


#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "MapViewController.h"
#import "MySound.h"
#define METERS_PER_MILE 1609.344

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    self.mapView.delegate = self;

    [self refreshSounds];
    
    [self.view addSubview:self.mapView];
    
    _refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 50, 50)];
    [_refreshButton addTarget:self action:@selector(refreshSounds) forControlEvents:UIControlEventTouchUpInside];
    [_refreshButton setBackgroundColor:[UIColor purpleColor]];
    [self.view addSubview:_refreshButton];
    
    //setup audio player
    _audioPlayer = [[AVPlayer alloc] init];
    
    //setup audio session
    _audioSession = [AVAudioSession sharedInstance];
    [_audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [_audioSession setActive:YES error:nil];
    
    //setup activity indicator
    CGFloat activityIndicatorWidth = 150;
    CGFloat activityIndicatorHeight = 150;
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - activityIndicatorWidth/2, self.view.frame.size.height/2 - activityIndicatorHeight/2, activityIndicatorWidth, activityIndicatorHeight)];
    [_activityIndicator setBackgroundColor:[UIColor grayColor]];
    _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma MapKit Delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    // CLLocationCoordinate2D zoomLocation =  [[[self.mapView userLocation] location] coordinate];
    
    //  MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    // [self.mapView setRegion:[self.mapView regionThatFits:viewRegion] animated:YES];
    
    
}

-(void)plotSounds:(NSData *)responseData{
  //  self.audioPlayers = [[NSMutableArray alloc] initWithCapacity:0];
    
    
    //remove all annotations currently on the map
    for (id<MKAnnotation> annotation in mapView.annotations) {
        [mapView removeAnnotation:annotation];
    }
    
    NSError* error;
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    
    NSArray *data = [json objectForKey:@"sounds"];
    
    for (NSArray *row in data) {
        NSNumber *latitude = [row valueForKey:@"latitude"];
        NSNumber *longitude = [row valueForKey:@"longitude"];
        
        NSString * name = @"sound";
        NSString * sound_url = [row valueForKey:@"sound_url"];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = latitude.doubleValue;
        coordinate.longitude = longitude.doubleValue;
        MySound *annotation = [[MySound alloc] initWithName:name sound_url:sound_url coordinate:coordinate] ;
        [self.mapView addAnnotation:annotation];
	}
}

/*
 - (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
 static NSString *identifier = @"MySound";
 if ([annotation isKindOfClass:[MySound class]]) {
 
 MKAnnotationView *annotationView = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
 if (annotationView == nil) {
 annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
 annotationView.enabled = YES;
 annotationView.canShowCallout = YES;
 //annotationView.image = [UIImage imageNamed:@"arrest.png"];//here we use a nice image instead of the default pins
 } else {
 annotationView.annotation = annotation;
 }
 
 return annotationView;
 }
 
 return nil;
 }
 */
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([_audioPlayer rate] != 0.0){ // if its playing

        [_audioPlayer pause]; //stop avplayer
        
        [_audioPlayer removeObserver:self forKeyPath:@"status"]; //clear status observer
        
        _audioPlayer = nil; //clear audio player
    }

    
    //get url from annotation
    NSLog(@"url for sound: %@", [view.annotation subtitle]);
    
    AVPlayer* player = [[AVPlayer alloc]
                             initWithURL:[NSURL URLWithString:[view.annotation subtitle]]];
    
    _audioPlayer = player;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[_audioPlayer currentItem]];
    [_audioPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    [_activityIndicator startAnimating];
    [self.view addSubview:_activityIndicator];
     }

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == _audioPlayer && [keyPath isEqualToString:@"status"]) {
        if (_audioPlayer.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
            
        } else if (_audioPlayer.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            [_audioPlayer play];
            [_activityIndicator stopAnimating];
            [_activityIndicator removeFromSuperview];
            
            
        } else if (_audioPlayer.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
            
        }
        
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    NSLog(@"audio did end");
    [_audioPlayer removeObserver:self forKeyPath:@"status"];
}



#pragma mark - Refresh button

-(void) refreshSounds{
    NSLog(@"refreshing sounds");
    
    NSString* sounds_route = [NSString stringWithFormat:@"%@/sounds", FOUNDLING_API];
    NSURL *finalURL = [[NSURL alloc] initWithString:sounds_route];
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:finalURL];
        [self performSelectorOnMainThread:@selector(plotSounds:)
                               withObject:data waitUntilDone:YES];
    });
    
    
}




@end
