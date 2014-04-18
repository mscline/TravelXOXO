//
//  MCAppDelegate.h
//  CSFriends
//
//  Created by xcode on 11/27/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCTag.h"

@interface MCAppDelegate : UIResponder <UIApplicationDelegate>

  @property (strong, nonatomic) UIWindow *window;

  @property NSMutableArray *locationsToImport;
  @property NSMutableArray *tagsToImport;
  @property NSString *timeAndDateOfImport;

@end
