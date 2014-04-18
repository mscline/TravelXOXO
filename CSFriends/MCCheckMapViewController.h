//
//  MCCheckMapViewController.h
//  CSFriends
//
//  Created by xcode on 11/27/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCLocation.h"
#import <MapKit/MapKit.h>

@interface MCCheckMapViewController : UIViewController <MKMapViewDelegate>

  @property MCLocation *locationObject;
  @property id pointerToMainViewController;

@end
