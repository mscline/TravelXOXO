//
//  MCAddPinViewController.h
//  CSFriends
//
//  Created by xcode on 11/27/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCAddPinViewController.h"
#import "MCLocation.h"

@protocol MCAddPinViewProtocol <NSObject>  // for main view controller, which will save pin

  -(void)addNewPinToListOfLocationsAndSave:(MCLocation *)newPin originalPin:(MCLocation *)oldPin;

@end


@protocol MCAddPinViewProtocol2 <NSObject>  // for detail view controller

  -(void)refreshScreen;

@end



@interface MCAddPinViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

  @property id<MCAddPinViewProtocol2>delegate;
  @property id pointerToMainViewController;

  @property NSMutableArray *listOfTags;             // to create checklist
  @property MCLocation *temporaryPinForEditing;
  @property MCLocation *originalPin;                // keep pointer so can replace 
                                                    //  with edited pin

@end
