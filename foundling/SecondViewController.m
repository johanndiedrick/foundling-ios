//
//  SecondViewController.m
//  ezsoundgltest
//
//  Created by Johann Diedrick on 1/29/14.
//  Copyright (c) 2014 Found Sound. All rights reserved.
//


#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)




#import "SecondViewController.h"
#import "MySound.h"
#define METERS_PER_MILE 1609.344

@interface SecondViewController ()

@end

@implementation SecondViewController

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
    self.audioPlayers = [[NSMutableArray alloc] initWithCapacity:0];
    
    
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
        
        //create an audio player for that annotation and add it to our array
        NSURL *audioURL = [NSURL URLWithString:sound_url];
        AudioPlayer *audioPlayer = [[AudioPlayer alloc] init];
        [audioPlayer setAudioURL:audioURL];
        [self.audioPlayers addObject:audioPlayer];
        
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
    //play audio
    for (int i=0; i<[self.audioPlayers count]; i++) {
        
        //pause all audio first
        
        if ([[self.audioPlayers[i] getAudioURL] absoluteString] != [view.annotation subtitle]) {
            //if([self.audioPlayers[i] state] == AudioPlayerStatePlaying){
                [self.audioPlayers[i] pause];
                //NSLog(@"Pausing audio");
                
                //[self.audioPlayers[i] pause];
           // }
        }
        
        
        //check to see find the audio player with the matching sound url
        if ([[[self.audioPlayers[i] getAudioURL] absoluteString] isEqual:[view.annotation subtitle]]) {
            NSLog(@"toggling audio %@", [view.annotation subtitle]);
            [self.audioPlayers[i] toggleAudio];
        }
        
        
    }
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
