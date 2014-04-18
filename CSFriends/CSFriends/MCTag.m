//
//  MCTag.m
//  CSFriends
//
//  Created by xcode on 12/7/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import "MCTag.h"

@implementation MCTag
  @synthesize tagName, selected, positionInTripAndArray, linesConnectingTripLocations, displayTripLines, finalDestination;

-(id)initWithTitle:(NSString *)tag isSelected:(BOOL)checkmark
{
    self = [super init];
    
    if(self){
        
        tagName = tag;
        selected = checkmark;
        finalDestination = @"";
        positionInTripAndArray = 1000;
    }

    return self;
}

-(NSDictionary *)convertToDictionary {
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    [dict setObject:tagName forKey:@"tagName"];
    [dict setObject:[NSString stringWithFormat:@"%i", selected] forKey:@"selected"];

    [dict setObject:finalDestination forKey:@"finalDestination"];
    [dict setObject:[NSString stringWithFormat:@"%i", displayTripLines] forKey:@"displayTripLines"];
    [dict setObject:[NSString stringWithFormat:@"%i", positionInTripAndArray] forKey:@"positionInTripAndArray"];
    
    // linesConnectingTripLocations (a MKPolygon) is recalculated when needed
    
    return dict;
}

-(id)initFromDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    if(self){
        
        tagName = dict[@"tagName"];
        selected = [dict[@"selected"] boolValue];

        finalDestination = dict[@"finalDestination"];
        displayTripLines = [dict[@"displayTripLines"] boolValue];
        positionInTripAndArray = (int)[dict[@"positionInTripAndArray"] integerValue];
        
        // linesConnectingTripLocations (a MKPolygon) is recalculated when needed
    }
    
    return self;
}

@end
