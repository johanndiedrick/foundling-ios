//
//  audioUploader.h
//  foundling
//
//  Created by Johann Diedrick on 8/8/13.
//  Copyright (c) 2013 Johann Diedrick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioUploader : NSObject
{
@private
NSString* soundFilePath;
NSString* dateString;
}

-(void) uploadAudio;

-(void) setSoundFilePath:(NSString*) _soundFilePath;

-(NSString*) getSoundFilePath;

-(void) setDateString:(NSString*) _dateString;

-(NSString*) getDateString;

@end
