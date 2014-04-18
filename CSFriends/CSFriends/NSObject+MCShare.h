//
//  NSObject+MCShare.h
//  CSFriends
//
//  Created by xcode on 1/31/14.
//  Copyright (c) 2014 xcode. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (MCShare)

  -(void)shareFileUsingActivityViewWithFileUrl:(NSURL *)url withPointerToActiveViewController_NeededSoCanPresentActivityVC:(id) pointerToMainController;

@end
