//
//  audioUploader.m
//  foundling
//
//  Created by Johann Diedrick on 8/8/13.
//  Copyright (c) 2013 Johann Diedrick. All rights reserved.
//

#import "AudioUploader.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

#define WAV_UPLOAD_PATH @"http://ec2-107-20-106-161.compute-1.amazonaws.com/uploadwav"

@implementation AudioUploader

-(void)setSoundFilePath:(NSString*) _soundFilePath{
    soundFilePath = _soundFilePath;
}

-(NSString*) getSoundFilePath{
    return soundFilePath;
}

-(void)setDateString:(NSString *)_dateString{
    dateString = _dateString;
}

-(NSString*) getDateString{
    return dateString;
}

-(void)uploadAudio{
    
    //get a date and time format
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy_HHmm"];
    dateString = [formatter stringFromDate:[NSDate date]];
    
    //get audio data
    NSData *audioData = [NSData dataWithContentsOfFile:[self getSoundFilePath]];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://ec2-107-20-106-161.compute-1.amazonaws.com/"]];
  
    NSString* filename = [NSString stringWithFormat:@"sound_%@.wav", dateString];
    
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/uploadwav" parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:audioData
                                    name:@"wav"
                                fileName:filename mimeType:@"audio/wav"];
        }];
    
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

         [operation setUploadProgressBlock:^(NSUInteger bytesWritten,
        long long totalBytesWritten,
        long long totalBytesExpectedToWrite) {
                 NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
             if (totalBytesWritten >= totalBytesExpectedToWrite) {
                 [self finishedUploading];
             }
             }];
            
            [httpClient enqueueHTTPRequestOperation:operation];
}

-(void)finishedUploading{
    [self.delegate finishedUploading];
}
@end
