//
//  MCArchiveFile.h
//  CSFriends
//
//  Created by xcode on 1/31/14.
//  Copyright (c) 2014 xcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCViewController.h"
#import "NSObject+MCShare.h"
#import "MCTag.h"
#import "MCLocation.h"
#import "MCAppDelegate.h"

@interface MCArchiveFileManager : NSObject <UIAlertViewDelegate>


//xxxxxxxxxxxxx
// EXPORT DATA
//xxxxxxxxxxxxx

  // puts all selected data in a dictionary, converts to NSData, and saves it
  //   (use the url property if want to access the data)

  -(id)initAndCreateArchiveWithTags:(NSArray *)tags andTheirFilteredLocations:(NSArray *)listOfFilteredPins;
  -(id)initAndCreateArchiveWithPins:(NSArray *)pins; 
  -(void)cleanUpOldFiles;

  @property NSURL *url;

  // an additional option is to share it with Apple's shareFileUsingActivityView
  //  using the attached category
 
  //-(void)shareFileUsingActivityViewWithFileUrl:(NSURL *)url withPointerToActiveViewController_NeededSoCanPresentActivityVC:(id) pointerToMainController


//xxxxxxxxxxxxx
// LOAD DATA
//xxxxxxxxxxxxx

  // to find data, use url provided by appDelegate when shared data sent to inbox 
  // use url to get archived dictionary 
  // unpack the the dictionary to get array of functing objects
  // photo images are saved to file

  // that is, use these functions to return listOfLocations, listOfTags, & the dateStamp (which will be used when you import the data)

  -(NSDictionary *)getDataAndConvertToDictionary:(NSURL *)incomingURL;  

  -(NSMutableArray *)unpackLocationData:(NSDictionary *)dict;
  -(MCTag *)addTagToLabelImportedLocations_ListOfLocationsToAddTagTo:(NSMutableArray *)locs ;
  -(NSMutableArray *)unpackTags:(NSDictionary *)dict tagAddingToImportedLocations:(MCTag *)labelTag;
  -(void)unpackPhotosAndSaveToFile:(NSDictionary *)dict unpackedLocations:(NSMutableArray *)locs;

  @property NSString *dateStamp;  

//xxxxxxxxxxxxxxxxxxx
// MERGE IMPORTED DATA
//xxxxxxxxxxxxxxxxxxx

-(void)checkToSeeIfNewDataAndPrepareForImport:(id)delegate; 
    
  // note: make the archiveFileManager a property so that it will be retained
  // (this method calls an alertView in the middle of the import, thus it ends, and is then resumed when the alertView calls its delegate method; if the archiveFileManager object is deallocated when the program stops, there is no one to receive the delegate call and you get a bad thread error)
  // it may have been better to set this up as a function, currently it directly accesses data from the app delegate (if in file, please refactor), may also be better to break this into three classes, export, load, merge

  @property MCAppDelegate *appDel;
  @property MCViewController *pointerToMainViewController;


@end
