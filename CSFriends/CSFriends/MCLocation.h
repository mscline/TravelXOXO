//
//  MCLocation.h
//  CSFriends
//
//  Created by xcode on 11/27/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MCTag.h"

@interface MCLocation : NSObject <MKAnnotation>

  //@property title                     //properties inherrited from MKAnnotation
  //          coordinate            

  @property NSString *country;
  @property NSString *location;
  @property NSString *notes;
  @property NSString *imageLocation;
  @property NSMutableArray *tags;

  @property BOOL displayPin;  // displayPinNotImage, aka, unselected
  @property MCTag *tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt;  // a temporary storage location, which simplifies code and improves performance



  -(id)initWithTitle:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinateLocation location:(NSString *)loc country:(NSString *)currentCountry notes:(NSString *)info imageLocation:(NSString *)imageName tags:(NSMutableArray *)locationTags;

  -(id)initFromDictionary:(NSDictionary *)dict;
  -(NSDictionary *)returnDictionaryOfLocationObject;  // ie archive
  -(NSData *)returnImageData;
  -(id)createCopy;


  -(void)editLocationWithTitle:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinateLocation location:(NSString *)loc country:(NSString *)currentCountry notes:(NSString *)info imageLocation:(NSString *)imageName tags:(NSMutableArray *)locationTags;

  -(void)editTagsAttachedToMCLocationObject_OldTagName: (NSString *)oldTagName newTagName_orEmptyStringToDelete:(NSString *)newTagName;  // to change tag names, enumerate thru list of tags (if loc doesn't have, will remain unaffected)

@end
