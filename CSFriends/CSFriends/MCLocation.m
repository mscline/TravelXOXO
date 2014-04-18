//
//  MCLocation.m
//  CSFriends
//
//  Created by xcode on 11/27/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import "MCLocation.h"

@implementation MCLocation
  @synthesize title, coordinate, imageLocation, notes, country, location, displayPin, tags, tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt;

-(id)initWithTitle:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinateLocation location:(NSString *)loc country:(NSString *)currentCountry notes:(NSString *)info imageLocation:(NSString *)imageName tags:(NSMutableArray *)locationTags;
{
    self = [super init];

    if(self){
    
        title = name;
        coordinate = coordinateLocation;
        imageLocation = imageName;
        notes = info;
        location = loc;
        country = currentCountry;
        displayPin = TRUE;
        tags = locationTags;
        
    }

    return self;
}

-(void)editLocationWithTitle:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinateLocation location:(NSString *)loc country:(NSString *)currentCountry notes:(NSString *)info imageLocation:(NSString *)imageName tags:(NSMutableArray *)locationTags
{
  
        title = name;
        coordinate = coordinateLocation;
        imageLocation = imageName;
        notes = info;
        location = loc;
        country = currentCountry;
        displayPin = TRUE;
        tags = locationTags;
}

-(id)initFromDictionary:(NSDictionary *)dict
{
    
    // convert strings of lat and long to cllocation
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([dict[@"latitude"] floatValue], [dict[@"longitude"] floatValue]);
    
    
    // unpack tags (each tag is a baby dictionary): convert tag to obj and put in arry
    NSMutableArray *arrayOfTagObjects = [NSMutableArray new];
    
    for(NSDictionary *tagInDictionaryFormat in dict[@"tags"]){
    
        [arrayOfTagObjects addObject:[[MCTag alloc] initFromDictionary:tagInDictionaryFormat]];
    }
    
    
    // initialize new location object
    MCLocation *myself = [self initWithTitle:dict[@"title"] 
                    coordinate:coord 
                      location:dict[@"location"] 
                       country:dict[@"country"] 
                         notes:dict[@"notes"] 
                 imageLocation:dict[@"imageLocation"]
                          tags:arrayOfTagObjects];
    
    myself.displayPin = TRUE;
    
    return myself;
}

-(NSDictionary *)returnDictionaryOfLocationObject
{
    
    // in order to save, need to convert objects into dictionaries and store in arry
    // then can just save it using Apple's save methods

    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:title forKey:@"title"];
    [dict setObject:imageLocation forKey:@"imageLocation"];
    [dict setObject:notes forKey:@"notes"];
    [dict setObject:country forKey:@"country"];
    [dict setObject:location forKey:@"location"];
    
    [dict setObject:[NSString stringWithFormat:@"%f",coordinate.longitude]forKey:@"longitude"];
    [dict setObject:[NSString stringWithFormat:@"%f",coordinate.latitude]forKey:@"latitude"]; 
    
    // next add tags: 
    // convert array of tags into an array of dictionaries
    // add to dict
    
    NSMutableArray *tagArray = [NSMutableArray new];
    
    for(MCTag *currentTag in tags) {
        
        [tagArray addObject: [currentTag convertToDictionary]];
        
    }
    
    [dict setObject:tagArray forKey:@"tags"];
    
    return dict;
}

-(NSData *)returnImageData
{

    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSURL *documentDirectory = [[fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [NSData dataWithContentsOfURL:[documentDirectory URLByAppendingPathComponent:imageLocation]];
    
}

-(id)createCopy
{
    // don't want to copy pointers to objects, want to duplicate all component objects
    // one of the approaches apple recommends is archiving/unarchiving (ie collect all data and init)
    
    return [[MCLocation alloc] initFromDictionary: [self returnDictionaryOfLocationObject] ];
    
}

-(void)editTagsAttachedToMCLocationObject_OldTagName: (NSString *)oldTagName newTagName_orEmptyStringToDelete:(NSString *)newTagName
{

    NSMutableArray *copyOfTagsToIterateThru = [NSMutableArray arrayWithArray:tags];
    
    for(MCTag *tag in copyOfTagsToIterateThru){
    
        if([tag.tagName isEqualToString: oldTagName]){

            if(![newTagName isEqualToString:@""]){

                tag.tagName = newTagName;
                return;
                
            }else{

                [tags removeObject:tag];
                return;
                
            }

        }
    }


}

@end
