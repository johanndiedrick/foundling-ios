//
//  FirstViewController.h
//  ezsoundgltest
//
//  Created by Johann Diedrick on 1/29/14.
//  Copyright (c) 2014 Found Sound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <GLKit/GLKit.h>
#import "AudioUploader.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "EZAudio.h"

@interface FirstViewController : UIViewController<EZMicrophoneDelegate, AVAudioPlayerDelegate,
AVAudioRecorderDelegate, CLLocationManagerDelegate, AudioUploaderDelegate>

#pragma mark audio

@property (strong, atomic) AVAudioSession *audioSession;

@property (strong, atomic) AVAudioRecorder *recorder;

@property (strong, atomic) AVAudioPlayer *player;

@property (strong, atomic) NSString *soundFilePath;

@property (strong, atomic) AudioUploader *audioUploader;


//location stuff
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) CLLocation *location;

//labels
@property (nonatomic, retain) UILabel* recordingLabel;
@property (nonatomic, retain) UILabel* recordingTimeLabel;

@property (nonatomic, retain) UILabel* uploadingAudioLabel;
@property (nonatomic, retain) UILabel* uploadingLocationLabel;

//timer for recording
@property (strong, atomic) NSTimer* recordingTimer;
@property (strong, atomic) NSString* recordingTime;

//activity indicator
@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;
@property (strong, nonatomic) UIView* darkView;



#pragma mark - Components
/**
 The OpenGL based audio plot
 */
@property (nonatomic,strong)  EZAudioPlotGL *audioPlotGL;

/**
 The microphone component
 */
@property (nonatomic,strong) EZMicrophone *microphone;
@end
