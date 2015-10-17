//
//  MyLocation.h
//  NestAwayChallenge
//
//  Created by Arun Chandran on 17/10/15.
//  Copyright (c) 2015 Adavya Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface MyLocation : NSObject <MKAnnotation>{
    
}

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate;
- (MKMapItem*)mapItem;



@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) CLLocationCoordinate2D theCoordinate;

@end