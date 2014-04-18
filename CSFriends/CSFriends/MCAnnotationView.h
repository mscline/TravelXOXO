//
//  MCAnnotationView.h
//  CSFriends
//
//  Created by xcode on 12/2/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MCLocation.h"

@interface MCAnnotationView : MKAnnotationView

  @property MCLocation *locationToDisplay;       // or use .annotation

  @property UIView *backgroundFrame;
  @property UIImageView *photo;                                                                     
  @property UILabel *textField; 

  @property UIFont *font;
  @property float scaleFactor;


  -(id)initFromLocationToDisplay:(MCLocation *)loc font:(UIFont *)font scaleFactor:(float)scaleFactor;
  -(void)setViewComponentsValues;

@end
