//
//  FirstViewController.m
//  ezsoundgltest
//
//  Created by Johann Diedrick on 1/29/14.
//  Copyright (c) 2014 Found Sound. All rights reserved.
//


#import "FirstViewController.h"

#define FOUND_SOUND_URL @"http://ec2-107-20-106-161.compute-1.amazonaws.com/"


@interface FirstViewController ()

@end

@implementation FirstViewController

@synthesize audioSession;
@synthesize recorder, player;
@synthesize soundFilePath;
@synthesize audioUploader;
@synthesize recordingLabel;
@synthesize uploadingAudioLabel;
@synthesize uploadingLocationLabel;
@synthesize recordingTimer;
@synthesize recordingTimeLabel;
@synthesize recordingTime;
@synthesize audioPlotGL;
@synthesize microphone;

#pragma mark - Initialization
-(id)init {
    self = [super init];
    if(self){
        [self initializeViewController];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initializeViewController];
    }
    return self;
}

#pragma mark - Initialize View Controller Here
-(void)initializeViewController {
    // Create an instance of the microphone and tell it to use this view controller instance as the delegate
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Programmatically create an audio plot
    self.audioPlotGL = [[EZAudioPlotGL alloc] initWithFrame:self.view.frame];
    
    
    // Background color (use UIColor for iOS)
    // Background color (use UIColor for iOS)
    // Background color
    self.audioPlotGL.backgroundColor = [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 1.0];
    // Waveform color
    self.audioPlotGL.color           = [UIColor colorWithRed:1.0 green:0.4 blue:0.8 alpha:1.0];
    // Plot type
    self.audioPlotGL.plotType        = EZPlotTypeBuffer;
    self.audioPlotGL.shouldMirror = NO;
    self.audioPlotGL.shouldFill = NO;


    [self.view addSubview:self.audioPlotGL];

    /*
     Start the microphone
     */
    [self.microphone startFetchingAudio];
    
    
    [self setupUI];
    [self setupAudio];
    [self setupAudioUploader];
    [self setupLocation];
    recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UI

- (void)setupUI{
    
    //get application width and height to use as global variables
    
    //set view background color
    self.view.backgroundColor = [UIColor whiteColor];
   // CGRect screenRect = [[UIScreen mainScreen] bounds];
   // CGFloat screenWidth = screenRect.size.width;
   // CGFloat screenHeight = screenRect.size.height;
    
    //setup record button
    UIButton *record = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [record setTitle:@"Record" forState:UIControlStateNormal];
    [record setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [record setFrame:CGRectMake(120, 300, 80, 40)]; //change from hardcoded values
    [record addTarget:self action:@selector(startRecording:) forControlEvents:UIControlEventTouchDown];
    [record addTarget:self action:@selector(stopRecording:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:record];
    
    //setup start recording label
    recordingLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    [recordingLabel setText:@"Recording"];
    [recordingLabel setTextColor:[UIColor purpleColor]];
    [recordingLabel setHidden:YES]; // hide recording label initially
    [self.view addSubview:recordingLabel];
    
    //setup recoring time label
    recordingTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 200, 100, 100)];
    [recordingTimeLabel setText:@"---"];
    [recordingTimeLabel setTextColor:[UIColor purpleColor]];
    [recordingTimeLabel setHidden:NO]; // hide recording label initially
    [self.view addSubview:recordingTimeLabel];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2) - 50/2 , (self.view.frame.size.height/2) - 50/2, 50, 50)];
    _darkView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_darkView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
    
}



#pragma mark - EZMicrophoneDelegate
#warning Thread Safety
// Note that any callback that provides streamed audio data (like streaming microphone input) happens on a separate audio thread that should not be blocked. When we feed audio data into any of the UI components we need to explicity create a GCD block on the main thread to properly get the UI to work.
-(void)microphone:(EZMicrophone *)microphone
 hasAudioReceived:(float **)buffer
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    // Getting audio data as an array of float buffer arrays. What does that mean? Because the audio is coming in as a stereo signal the data is split into a left and right channel. So buffer[0] corresponds to the float* data for the left channel while buffer[1] corresponds to the float* data for the right channel.
    
    // See the Thread Safety warning above, but in a nutshell these callbacks happen on a separate audio thread. We wrap any UI updating in a GCD block on the main thread to avoid blocking that audio flow.
    dispatch_async(dispatch_get_main_queue(),^{
        // All the audio plot needs is the buffer data (float*) and the size. Internally the audio plot will handle all the drawing related code, history management, and freeing its own resources. Hence, one badass line of code gets you a pretty plot :)
        [self.audioPlotGL updateBuffer:buffer[0] withBufferSize:bufferSize];
    });
}

-(void)microphone:(EZMicrophone *)microphone hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription {
    // The AudioStreamBasicDescription of the microphone stream. This is useful when configuring the EZRecorder or telling another component what audio format type to expect.
    // Here's a print function to allow you to inspect it a little easier
    [EZAudio printASBD:audioStreamBasicDescription];
}

-(void)microphone:(EZMicrophone *)microphone
    hasBufferList:(AudioBufferList *)bufferList
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    // Getting audio data as a buffer list that can be directly fed into the EZRecorder or EZOutput. Say whattt...
}

#pragma mark audio functions

-(void)startRecording:(id)sender {
    
    if (!recorder.isRecording) {
        NSLog(@"Start recording");
        
        //display our labels
        [recordingLabel setHidden:NO];
        [recordingTimeLabel setHidden:NO];
        
        [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
        [recorder record];
        //set up timer
    }
}

-(void)updateSlider{
    if (recorder.isRecording) {
        float minutes = floor(recorder.currentTime/60);
        float seconds = recorder.currentTime - (minutes * 60);
        
        recordingTime =   [[NSString alloc] initWithFormat:@"%0.0f.%0.0f",
                           minutes, seconds];
        
        NSLog(recordingTime);
        
        recordingTimeLabel.text = recordingTime;
        
        
    }
}

-(void)stopRecording:(id)sender {
    NSLog(@"Stop recording");
    
    //hide recording labels
    [recordingLabel setHidden:YES];
    [recordingTimeLabel setHidden:YES];
    
    [recorder stop];
    if(!recorder.recording){
        NSError *error;
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:&error];
        
        player.delegate = self;
        
        if (error) {
            NSLog(@"error: %@", [error localizedDescription]);
        }else{
            NSLog(@"Playing back audio");
            [player play];
            //show upload icon and upload audio
            
            [self.view addSubview:_darkView];
            [_activityIndicator startAnimating];
            [_darkView addSubview:_activityIndicator];
            [audioUploader uploadAudio];
            [self sendLocation];
        }
    }
}


- (IBAction)play:(id)sender {
    if(!recorder.recording){
        NSError *error;
        
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:&error];
        
        player.delegate = self;
        
        if (error) {
            NSLog(@"error: %@", [error localizedDescription]);
        }else{
            [player play];
        }
    }
}

- (IBAction)stop:(id)sender {
    
    if(recorder.recording){
        NSLog(@"Stop recording");
        [recorder stop];
        NSLog(@"Uploading audio");
        [audioUploader uploadAudio];
        [self sendLocation];
        
        
        
    }else if(player.playing){
        [player stop];
    }
    
}

-(void)setupAudio{
    //disable all buttons except record button
    
    //get dir to save our audio file
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    
    NSString *docsDir = dirPaths[0];
    
    soundFilePath = [docsDir stringByAppendingFormat:@"sound.wav"];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    //set up recorder
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                    [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                                    [NSNumber numberWithInt:AVAudioQualityMin],AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],AVEncoderBitRateKey,
                                    [NSNumber numberWithInt:2],AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],AVSampleRateKey,
                                    nil];
    
    NSError *error = nil;
   
    //new code for ios7
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [audioSession setActive:YES error:nil];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:&error];
    
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    } else{
        [recorder prepareToRecord];
    }
    
    
}

-(void) setupAudioUploader{
    audioUploader = [[AudioUploader alloc] init];
    [audioUploader setSoundFilePath:soundFilePath];
    audioUploader.delegate = self;
}

-(void) sendLocation{
    NSError *error = nil;
    
    NSDictionary *locationData = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"%f", self.location.coordinate.latitude], @"latitude",
                                  [NSString stringWithFormat:@"%f", self.location.coordinate.longitude], @"longitude",
                                  [NSString stringWithFormat:@"%@", [audioUploader getDateString]], @"sound_date",
                                  
                                  nil];
    
    //convert object to data
    //  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:locationData options:NSJSONWritingPrettyPrinted error:&error];
    
    //  NSLog([[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    NSURL *url = [NSURL URLWithString:FOUND_SOUND_URL];
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    client.parameterEncoding = AFJSONParameterEncoding;
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    [client postPath:@"/receivejson"
          parameters:locationData
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSLog(@"RESPONSE: %@", responseObject);
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 if (error)
                     NSLog(@"%@", [error localizedDescription]);
             }];
    
    
}

#pragma mark AVFoundation Delegate

-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    //
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"Decode error occured");
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"Finished recording audio");
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    NSLog(@"Encode error occured");
}

#pragma mark CoreLocation Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    self.location = locations.lastObject;
    
}

-(void)setupLocation{
    //location stuff
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; //maybe try best 10m
    [self.locationManager startUpdatingLocation];
    
    //set up location object
    self.location = [[CLLocation alloc] init];
    
}

-(void) finishedUploading{
    NSLog(@"finished uploading");
    [_activityIndicator stopAnimating];
    [_activityIndicator removeFromSuperview];
    [_darkView removeFromSuperview];
}

@end
