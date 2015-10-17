//
//  ViewController.m
//  NestAwayChallenge
//
//  Created by Arun Chandran on 17/10/15.
//  Copyright (c) 2015 Adavya Technologies. All rights reserved.
//

#import "ViewController.h"
#import "MyLocation.h"



#define METERS_PER_MILE 1609.344

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"yeah this works!!!");
    
    _toolBar.hidden = YES;
    
    areaSelected = NO;
    
    [self getMeHouses];
    //[self addAnnotation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

-(IBAction)showMeTrends{
    NSLog(@"Hash Tags are %@",hashTags);
    
    UIAlertView *hashAlert = [[UIAlertView alloc] initWithTitle:@"Trending" message:hashTags delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [hashAlert show];
    
}

-(IBAction)selectArea:(id)sender{
    if (!areaSelected) {
        UIAlertView* message = [[UIAlertView alloc] initWithTitle:@"Swipe to select" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [message show];
        
        
        OverlaySelectionView* overlay = [[OverlaySelectionView alloc] initWithFrame: self.view.frame];
        overlay.delegate = self;
        [self.view addSubview: overlay];
        
        
        selectAreaButton.style = UIBarButtonItemStyleDone;
        selectAreaButton.title = @"Reset";
    }
    else{
        
        selectAreaButton.title = @"Swipe";
        [_mapView removeAnnotations:_mapView.annotations];
        [self addAnnotations:serverLocationsArray];
    }
    
    areaSelected = !areaSelected;
    
}


-(void)addAnnotations:(NSArray*)locationsArray{
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 13.001426;
    zoomLocation.longitude= 77.717388;
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 25.5*METERS_PER_MILE);
    
    // 3
    [_mapView setRegion:viewRegion animated:YES];
    
    
    for (int i=0; i<[locationsArray count]; i++) {
        NSDictionary *locDetailDict = [locationsArray objectAtIndex:i];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[locDetailDict valueForKey:@"lat_double"] doubleValue];
        coordinate.longitude = [[locDetailDict valueForKey:@"long_double"] doubleValue];
        NSString *name = [locDetailDict objectForKey:@"title"];
        NSString *address = [locDetailDict objectForKey:@"bhk_details"];
        MyLocation *annotation = [[MyLocation alloc] initWithName:name address:address coordinate:coordinate] ;
        [_mapView addAnnotation:annotation];
    }
    
    
}

#pragma mark Server Calls handling
-(void)getMeHouses{
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://a88a4240.ngrok.io/"]];
    _currentConnection = [[NSURLConnection alloc]initWithRequest:req delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(!_serverData)
        _serverData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_serverData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *jsonParsingError = nil;
   
    NSError *e = nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:_serverData options: NSJSONReadingMutableContainers error: &jsonParsingError];
    
    if (!jsonDictionary) {
        NSLog(@"Error parsing JSON: %@", e);
    } else {
        
        NSArray *jsonArray = [jsonDictionary objectForKey:@"houses"];
        serverLocationsArray = [[NSMutableArray alloc] initWithArray:jsonArray];
        
        //NSLog(@"%@",jsonArray);
        [self addAnnotations:jsonArray];
        [self generateHashTags:jsonArray];
        
        _toolBar.hidden = NO;
    }
    
}
#pragma mark -


#pragma mark Map Annotations Management
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    
    
    //static NSString *identifier = [NSString stringWithFormat:@"%@%@",[annotation title], [annotation subtitle]];
    
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[MyLocation class]]) {
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"residence.png"];//here we use a nice image instead of the default pins
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}

#pragma mark -


-(void)generateHashTags:(NSArray*)jsonArray{
    NSString *bhk_details;
    NSString *house_type;
    NSString *rent;
    NSString *gender;
    
    NSString *total_bhk_details = [[NSString alloc] init];
    NSString *total_house_type = [[NSString alloc] init];
    NSString *total_rent = [[NSString alloc] init];
    NSString *total_gender = [[NSString alloc] init];
    
    for (int i=0; i<[jsonArray count]; i++) {
        
        total_bhk_details = [NSString stringWithFormat:@"%@-%@", total_bhk_details,[[jsonArray objectAtIndex:i] valueForKey:@"bhk_details"]];
        
        total_house_type = [NSString stringWithFormat:@"%@-%@", total_house_type,[[jsonArray objectAtIndex:i] valueForKey:@"house_type"]];
        
        total_rent = [NSString stringWithFormat:@"%@-%@", total_rent,[[jsonArray objectAtIndex:i] valueForKey:@"min_rent"]];
        
        total_gender = [NSString stringWithFormat:@"%@-%@", total_gender,[[jsonArray objectAtIndex:i] valueForKey:@"gender"]];
    }
    
    bhk_details = [self wordMagic:total_bhk_details];
    house_type = [self wordMagic:total_house_type];
    rent = [self wordMagic:total_rent];
    gender = [self wordMagic:total_gender];
    
    NSLog(@"Hash Tags Are\n BHK Deatils = %@\n House Type = %@\n Rent =%@\n Gender = %@\n",bhk_details, house_type, rent, gender);
    
    hashTags = [NSString stringWithFormat:@"#%@ #%@ #%@ #%@", bhk_details, house_type, rent, gender];
}

-(NSString*)wordMagic:(NSString*)totalSlug{
    
    
    NSLog(@"%@", totalSlug);
    /*
    NSString *string = [[NSString alloc] init];
    for (int i=0; i<[jsonArray count]; i++) {
        string = [[jsonArray objectAtIndex:i] valueForKey:@"slug"];
        totalSlug = [totalSlug stringByAppendingString:string];
    }
    */
    //NSLog(@"Total Slug = %@", totalSlug);
    
    //NSString *content = @"Hello Arun irulam Hello world Arun";
    NSArray *myWords = [totalSlug componentsSeparatedByString:@"-"];
    
    NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:myWords];
    NSMutableArray *dictArray = [NSMutableArray array];
    
    [countedSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [dictArray addObject:@{@"word": obj,
                               @"count": @([countedSet countForObject:obj])}];
    }];
    
    //NSLog(@"Words sorted by count: %@", [dictArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO]]]);
    
    NSLog(@"%@", [[[dictArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO]]] objectAtIndex:0] objectForKey:@"word"]);
    
    return [[[dictArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO]]] objectAtIndex:0] objectForKey:@"word"];
}


- (void) areaSelected: (CGRect)screenArea
{
    //selectAreaButton.style = UIBarButtonItemStyleBordered;
    //selectAreaButton.title = @"Reset";
    
    CGPoint point = screenArea.origin;
    // we must account for upper nav bar height!
    point.y -= 44;
    CLLocationCoordinate2D upperLeft = [_mapView convertPoint: point toCoordinateFromView: _mapView];
    point.x += screenArea.size.width;
    CLLocationCoordinate2D upperRight = [_mapView convertPoint: point toCoordinateFromView: _mapView];
    point.x -= screenArea.size.width;
    point.y += screenArea.size.height;
    CLLocationCoordinate2D lowerLeft = [_mapView convertPoint: point toCoordinateFromView: _mapView];
    point.x += screenArea.size.width;
    CLLocationCoordinate2D lowerRight = [_mapView convertPoint: point toCoordinateFromView: _mapView];
    
    searchBounds.minLatitude = MIN(lowerLeft.latitude, lowerRight.latitude);
    searchBounds.minLongitude = MIN(upperLeft.longitude, lowerLeft.longitude);
    searchBounds.maxLatitude = MAX(upperLeft.latitude, upperRight.latitude);
    searchBounds.maxLongitude = MAX(upperRight.longitude, lowerRight.longitude);
    
    // TODO: comment out to keep search rectangle on screen
    [[self.view.subviews lastObject] removeFromSuperview];
    
    //[self performSelectorInBackground: @selector(lookupHistoryByArea) withObject: nil];
    
    NSLog(@"searchBounds are Min lat %f, min long %f, max lat %f, max long %f", searchBounds.minLatitude, searchBounds.minLongitude, searchBounds.maxLatitude, searchBounds.maxLongitude);
    if (!refinedArray)
        refinedArray = [[NSMutableArray alloc] init];
    else
        [refinedArray removeAllObjects];
    
    for (int i=0; i<[serverLocationsArray count]; i++) {
        CLLocationCoordinate2D currentLoc = [self getCoordinate:[serverLocationsArray objectAtIndex:i]];
        if (currentLoc.latitude>searchBounds.minLatitude&&
            currentLoc.longitude>searchBounds.minLongitude&&
            currentLoc.latitude<searchBounds.maxLatitude&&
            currentLoc.longitude<searchBounds.maxLongitude) {
            
            [refinedArray addObject:[serverLocationsArray objectAtIndex:i]];
        }
    }
    
    NSLog(@"Refined Array is %@ and count is %lu", refinedArray, (unsigned long)[refinedArray count]);
    
    [_mapView removeAnnotations:_mapView.annotations];
    [self addAnnotations:refinedArray];
}



-(CLLocationCoordinate2D)getCoordinate:(NSDictionary*)locDict{
 
    double lat = [[locDict objectForKey:@"lat_double"] doubleValue];
    double longi = [[locDict objectForKey:@"long_double"] doubleValue];

    CLLocationCoordinate2D loc;
    loc.latitude = lat;
    loc.longitude = longi;
    
    return loc;
}



@end
