//
//  MCTag.h
//  CSFriends
//
//  Created by xcode on 12/7/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MCTag : NSObject

  @property NSString *tagName;
  @property BOOL selected;

  // only used in master tag list
  @property BOOL displayTripLines;
  @property NSString *finalDestination;
  @property MKPolyline *linesConnectingTripLocations;

  // only used by tags attached to locations
  @property int positionInTripAndArray;  

  -(id)initWithTitle:(NSString *)tag isSelected:(BOOL)checkmark;
  -(id)initFromDictionary:(NSDictionary *)dict;
  -(NSDictionary *)convertToDictionary;

@end
