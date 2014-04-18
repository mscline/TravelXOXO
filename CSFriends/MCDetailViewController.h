//
//  MCDetailViewController.h
//  CSFriends
//
//  Created by xcode on 12/9/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCLocation.h"
#import "MCViewController.h"
#import "MCAddPinViewController.h"

@interface MCDetailViewController : UIViewController <MCAddPinViewProtocol2, UIScrollViewDelegate>
 
  @property NSArray *listOfPinsToDisplay;
  @property NSArray *listOfTags;
  @property id pointerToMainViewController;  // need to pass pointer to 
                                             // add pin view controller
                                             // which will tell main view controller
                                             // to save pin
@end

