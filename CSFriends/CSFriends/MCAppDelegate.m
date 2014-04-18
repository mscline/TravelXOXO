//
//  MCAppDelegate.m
//  CSFriends
//
//  Created by xcode on 11/27/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import "MCAppDelegate.h"
#import "MCArchiveFileManager.h"

@implementation MCAppDelegate
  @synthesize locationsToImport, tagsToImport, window, timeAndDateOfImport;

// IMPORT FILE WITH URL
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{

    if(url){

        // unpack data and save in App Delegate properties
        
        MCArchiveFileManager *archiveFileManager = [[MCArchiveFileManager alloc]init];
        NSDictionary *dict = [archiveFileManager getDataAndConvertToDictionary: url];
        
        locationsToImport = [archiveFileManager unpackLocationData: dict];
        MCTag *tagToLabelImportedLocations = [archiveFileManager addTagToLabelImportedLocations_ListOfLocationsToAddTagTo:locationsToImport];       
        
        tagsToImport = [archiveFileManager unpackTags:dict tagAddingToImportedLocations:tagToLabelImportedLocations];
        
        [archiveFileManager unpackPhotosAndSaveToFile:dict unpackedLocations:locationsToImport];
  
        timeAndDateOfImport = archiveFileManager.dateStamp;
        
        // delete old file
        NSFileManager *fileManger = [NSFileManager defaultManager];
        [fileManger removeItemAtURL:url error:nil];
    NSLog(@"in app delegate, deleting file - %@", url);
    }
    
    // MCViewController is responsible for checking for data and loading on convenience
    // (if you are working in another view controller, it won't interrupt you)
    
    // the notification center is used to notify ViewControllers (ie, the view controllers add an observer)
    // (this seems to be the prefered method, but I don't care for it because there is no
    //  need for this much decoupling, you can't read program flow, and is not DRY ... plain sloppy)
    
    return YES;
}


// BOILER PLATE
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
