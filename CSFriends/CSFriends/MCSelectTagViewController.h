//
//  MCSelectTagViewController.h
//  CSFriends
//
//  Created by xcode on 12/6/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCTag.h"

@interface MCSelectTagViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UITextFieldDelegate>

  @property id delegate;
  @property NSMutableArray *listOfTags;

  -(void)saveListOfTags;

@end
