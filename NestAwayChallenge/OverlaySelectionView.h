//
//  OverlaySelectionView.h
//  NestAwayChallenge
//
//  Created by Arun Chandran on 17/10/15.
//  Copyright (c) 2015 Adavya Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

#import <QuartzCore/QuartzCore.h>

@protocol OverlaySelectionViewDelegate
// callback when user finishes selecting map region
- (void) areaSelected: (CGRect)screenArea;
@end


@interface OverlaySelectionView : UIView {
@private

    CGRect dragAreaBounds;
    //id<OverlaySelectionViewDelegate> delegate;
}

@property (nonatomic, assign) id<OverlaySelectionViewDelegate> delegate;

@end