//
//  NSObject+MCShare.m
//  CSFriends
//
//  Created by xcode on 1/31/14.
//  Copyright (c) 2014 xcode. All rights reserved.
//

#import "NSObject+MCShare.h"

@implementation NSObject (MCShare)

#pragma mark Use Apple Share Activity Sheet

-(void)shareFileUsingActivityViewWithFileUrl:(NSURL *)url withPointerToActiveViewController_NeededSoCanPresentActivityVC:(id) pointerToMainController
{
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:[NSArray arrayWithObject: url] applicationActivities:nil];
    
    // notes: applicationActivies allows you to perform custom services (or just set to nil)      
    // may also provide proxy objects to stand in for objects (see ref)
    
    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePostToTwitter, UIActivityTypeSaveToCameraRoll, UIActivityTypePostToWeibo, UIActivityTypePostToVimeo, UIActivityTypePostToFlickr];
    
    [pointerToMainController presentViewController:activityVC animated:YES completion:nil];
    
}

@end


// According to Apple 
// When presenting the view controller, you must do so using the appropriate means for the current device. On iPad, you must present the view controller in a popover.  (It is a container for a view controller.) On iPhone and iPod touch, you must present it modally.
// . . . but it just crahes when I tried it, it dealloc too soon
// and it runs fine without it (maybe it is old documentation?)
// prefer not to use the popover anyway

// REMOVED CODE:

// NSString *deviceModel = (NSString*)[UIDevice currentDevice].model;  // (could use the idom ... = ipad, but doesn't work if running iPhone app on iPad)
// if ([[deviceModel substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"iPad"]) {
//        
//        UIPopoverController *pc = [[UIPopoverController alloc]initWithContentViewController:activityVC];
//        [pc presentPopoverFromRect:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, .75 * self.view.frame.size.width, .75 * self.view.frame.size.height) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
//        
//        
//    } else{
//        
//        [self presentViewController:activityVC animated:YES completion:nil];
//    }


