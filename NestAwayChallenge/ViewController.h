//
//  ViewController.h
//  NestAwayChallenge
//
//  Created by Arun Chandran on 17/10/15.
//  Copyright (c) 2015 Adavya Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "OverlaySelectionView.h"

typedef struct {
    CLLocationDegrees minLatitude;
    CLLocationDegrees maxLatitude;
    CLLocationDegrees minLongitude;
    CLLocationDegrees maxLongitude;
} LocationBounds;

@interface ViewController : UIViewController<MKMapViewDelegate, OverlaySelectionViewDelegate>{
    
    NSString *hashTags;
    LocationBounds searchBounds;
    
    NSMutableArray *serverLocationsArray;
    NSMutableArray *refinedArray;
    
    IBOutlet UIBarButtonItem *selectAreaButton;
    
    BOOL areaSelected;
}



@property(weak, nonatomic) IBOutlet MKMapView *mapView;
@property(weak, nonatomic) IBOutlet UIButton *trendButton;
@property(weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property(strong, nonatomic) NSMutableData *serverData;
@property(strong, nonatomic) NSURLConnection *currentConnection;

-(IBAction)showMeTrends;
-(IBAction)selectArea:(id)sender;
-(void)getMeHouses;
-(void)addAnnotations:(NSArray*)locationsArray;



@end

