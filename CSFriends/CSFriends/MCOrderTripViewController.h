//
//  MCOrderTripViewController.h
//  CSFriends
//
//  Created by xcode on 1/16/14.
//  Copyright (c) 2014 xcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCTag.h"
#import "MCViewController.h"
#import "MCSelectTagViewController.h"

@interface MCOrderTripViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

  @property MCTag *tagSelected;
  @property MCSelectTagViewController *delegate;
  @property MCViewController *pointerToMainViewController;

@end
