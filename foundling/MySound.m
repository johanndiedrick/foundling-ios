//
//  MySound.m
//  MapKitTutorial
//
//  Created by Johann Diedrick on 8/15/13.
//  Copyright (c) 2013 Johann Diedrick. All rights reserved.
//

#import "MySound.h"
#import <AddressBook/AddressBook.h>


@interface MySound ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sound_url;
@property (nonatomic, assign) CLLocationCoordinate2D theCoordinate;
@end

@implementation MySound

- (id)initWithName:(NSString*)name sound_url:(NSString*)sound_url coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        if ([name isKindOfClass:[NSString class]]) {
            self.name = name;
        } else {
            self.name = @"";
        }
        self.sound_url = sound_url;
        self.theCoordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    return _name;
}

- (NSString *)subtitle {
    return _sound_url;
}

- (CLLocationCoordinate2D)coordinate {
    return _theCoordinate;
}

- (MKMapItem*)mapItem {
    //NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey : _address};
    
    //MKPlacemark *placemark = [[MKPlacemark alloc]
    //                          initWithCoordinate:self.coordinate
    //                         addressDictionary:addressDict];
    
    // MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    //mapItem.name = self.title;
    
    //return mapItem;
    return 0;
}

@end
