//
//  MCArchiveFile.m
//  CSFriends
//
//  Created by xcode on 1/31/14.
//  Copyright (c) 2014 xcode. All rights reserved.
//

#import "MCArchiveFileManager.h"
#import "MCLocation.h"
#import "MCTag.h"

@interface MCArchiveFileManager ()

  @property NSMutableArray *dups;
  @property NSMutableArray *nonDups;

@end

@implementation MCArchiveFileManager
  @synthesize url, dateStamp, dups, nonDups, appDel, pointerToMainViewController;


#pragma mark Exporting Data

-(id)initAndCreateArchiveWithPins:(NSArray *)pins 
{
    self = [super init];
    
    if(self){
    
        NSArray *tagsForPins = [self getTagsForSelectedPins:pins];
        
        NSData *archiveFile = [self exportDataWithPins:pins withTags:tagsForPins];
        [self saveExportedData: archiveFile];

    }

    return self;
    
}

-(id)initAndCreateArchiveWithTags:(NSArray *)tags andTheirFilteredLocations:(NSArray *)listOfFilteredPins
{
    self = [super init];
    
    if(self){
        
        NSData *archiveFile = [self exportDataWithPins:listOfFilteredPins withTags:tags];
        [self saveExportedData: archiveFile];

    }
    
    return self;
    
}

-(NSArray *)getTagsForSelectedPins:(NSArray *)pins 
{
    // make list of tags belonging to pins (with dups)
    NSMutableArray *allUsedTags = [NSMutableArray new];
    
    for(MCLocation *loc in pins){
        
        [allUsedTags addObjectsFromArray: loc.tags];
    }
    
    
    // make a new list of tags without dups
    NSMutableArray *usedTagsWithoutDups = [NSMutableArray new];
    
    for(MCTag *tag in allUsedTags){
        
        // add to list if not already in list
        BOOL inList = FALSE;
        
        for(MCTag *tag2 in usedTagsWithoutDups){
            
            if([tag.tagName isEqualToString: tag2.tagName]){
                
                inList = TRUE;
                break;
            }
        }
        
        if(!inList) { 
            
            [usedTagsWithoutDups addObject: tag]; }
    }
    
    return (NSArray *)usedTagsWithoutDups;
    
}

-(NSData *)exportDataWithPins:(NSArray *)pins withTags:(NSArray *)tags 
{
    
    // pack listOfFilteredTags, listOfPins, and photos (stored as NSData)
    //  into a dictionary and save the whole thing as NSData (ie, serialize it)
    
    // convert location objects to dictionaries and save in array
    NSMutableArray *locations = [NSMutableArray new];
    
    for(MCLocation *loc in pins){
        
        [locations addObject: [loc returnDictionaryOfLocationObject]];}
    
    
    // convert tag objects and save in an array
    NSMutableArray *tagz = [NSMutableArray new];
    
    for(MCTag *tag in tags){
        
        [tagz addObject: [tag convertToDictionary]]; }
    
    
    // load photos and their names and save in dictionary
    // save dictionaries in an array
    
    NSMutableArray *photos = [NSMutableArray new];
    
    // each location has a photo (or could have one), look it up
    for(MCLocation *loc in pins){
 
        NSData *data = [loc returnImageData];
        
        if(data){
            
            // make dictionary
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: data, @"data", loc.imageLocation, @"imageLocation", nil];

            // add to array
            [photos addObject: dict];
                
        }
    }

    
    // put all inside a dictionary and convert to NSData
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:photos, @"photos", locations, @"locations", tagz, @"tagz", nil];
   
    //DEBUG (save as plist instead of txo so can see output)
    //[self debug_saveAsPlist:dict];
   
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject: dict];

    return archivedData;
    
}

-(void)saveExportedData:(NSData *)archivedData
{
    // save
    NSString *fileName = [NSString stringWithFormat:@"ArchiveFile%f.txo",[NSDate timeIntervalSinceReferenceDate]];
    
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSURL *documentDirectory = [[fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [documentDirectory URLByAppendingPathComponent:fileName];
    
    [archivedData writeToURL:url atomically:YES]; 
    
}

-(void)debug_saveAsPlist:(NSDictionary *)dict
{
    // to check file contents, save as plist instead
    NSString *fileName = [NSString stringWithFormat:@"checkThisFile%f.plist",[NSDate timeIntervalSinceReferenceDate]];
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSURL *documentDirectory = [[fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [documentDirectory URLByAppendingPathComponent:fileName];
    NSLog(@"\n\nurl: %@\n\n", url);  
    
    [dict writeToURL:url atomically:YES];  
    
}


-(void)cleanUpOldFiles
{
    // delete all txo files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *urlOfFile = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]; 
    NSArray *filesInDirectory = [fileManager contentsOfDirectoryAtURL:urlOfFile includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:nil];  
    
    for(NSURL *fileName in filesInDirectory){
        
        if([[fileName pathExtension] isEqualToString:@"txo"]){
            
            [fileManager removeItemAtURL:fileName error:nil];  
        }
        
    }
    
}


#pragma mark Loading Data

-(NSDictionary *)getDataAndConvertToDictionary:(NSURL *)incomingURL
{

    NSData *data = [NSData dataWithContentsOfURL:incomingURL]; 
    NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData: data];

    return dict;
    
}

-(NSMutableArray *)unpackLocationData:(NSDictionary *)dict
{
    NSMutableArray *arryOfLocationsDicts = dict[@"locations"];
    NSMutableArray *locations = [NSMutableArray new];   
    
    for(NSDictionary *dictOfLoc in arryOfLocationsDicts){
    
        [locations addObject: [[MCLocation alloc] initFromDictionary:dictOfLoc] ]; }
    
    for(MCLocation *loc in locations){NSLog(@"Unpack Locations:%@", loc.title);} 
    
    return locations;
}


-(MCTag *)addTagToLabelImportedLocations_ListOfLocationsToAddTagTo:(NSMutableArray *)locs 
{    
    
    // create tag to insert
    NSDate *date = [NSDate date];
    dateStamp =[NSString stringWithFormat:@"Data Imported: %@",[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterLongStyle]];
        
    MCTag *importedTag = [[MCTag alloc] initWithTitle:[NSString stringWithFormat:@"<%@>", dateStamp] isSelected:YES];
    
    // add imported tag to list of tags property for each location object
    for(MCLocation *loc in locs){
        
        [loc.tags addObject: importedTag]; 
        
    }
    
    return importedTag;
}

-(NSMutableArray *)unpackTags:(NSDictionary *)dict tagAddingToImportedLocations:(MCTag *)labelTag
{
    // uppack tags
    NSMutableArray *arryOfTagDicts = dict[@"tagz"];
    NSMutableArray *tags = [NSMutableArray new];
    
    for(NSDictionary *dictOfTag in arryOfTagDicts){
    
        [tags addObject: [[MCTag alloc] initFromDictionary: dictOfTag] ];}
    
    [tags addObject: labelTag];
     
    for(MCTag *tag in tags){ NSLog(@"Unpack Tags %@", tag.tagName);}
    
    return tags;
}

-(void)unpackPhotosAndSaveToFile:(NSDictionary *)dict unpackedLocations:(NSMutableArray *)locs
{    
    // get individual photos (NSData) from archive and save as separate files
    // rename giving unique identifier to prevent potential problems with file name duplication
    // after saving photos, updates location object which stores the file name
    
    // save photos
    NSMutableArray *arryOfPhotos_NSData = dict[@"photos"];
    
    for(NSDictionary *dictOfPhoto in arryOfPhotos_NSData){
    
        NSString *oldFileName = dictOfPhoto[@"imageLocation"];
        NSString *newFileName = [NSString stringWithFormat:@"%f",[NSDate timeIntervalSinceReferenceDate]];
        
        NSData *fileData = dictOfPhoto[@"data"];

        // save file
        NSFileManager *fileManger = [NSFileManager defaultManager];
        NSURL *documentDirectory = [[fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        [fileData writeToURL:[documentDirectory URLByAppendingPathComponent:newFileName] atomically:YES];
        
        // update corresponding location
        for(MCLocation *loc in locs){
        
            
                if([loc.imageLocation isEqualToString:oldFileName]){
                
                    loc.imageLocation = newFileName;
                    break;
                }
        
        }
        
    }
      
}


#pragma mark Merge Imported Data

-(void)checkToSeeIfNewDataAndPrepareForImport:(id)delegate
{
    
    appDel = [[UIApplication sharedApplication] delegate];
    pointerToMainViewController = delegate;
    dateStamp = appDel.timeAndDateOfImport;
    
    if(appDel.locationsToImport || appDel.tagsToImport){
        
        // check to see if imported tags already in system
        dups = [NSMutableArray new];
        nonDups = [NSMutableArray new];
        
        [self findDupsAndNonDups];
        
        // if no dups, start import
        if([dups count] == 0){
        
            [pointerToMainViewController importNewData];
            return;
            
        } else {
        
            // if dups, ask user if want to merge or not
            NSString *str = @"Imported Tags Already Exist:";
            
            for(MCTag *tag in dups){
                
                str = [NSString stringWithFormat:@"%@\n%@", str, tag.tagName];  
                
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:str message:@"When you select a tag, you are selecting a group of pins.  To add the imported pins with a tag \"Europe,\" for example, to your tags labelled \"Europe,\" select Merge.  Otherwise, select Rename Imported Tags.\n\nYou are free to edit tags names, after you have completed the import.  The edit button in the upper right corner of your screen.  \n\nTo merge manually: Rename tag to same name as the tag you wish to merge with, thus changing the tag attached to all corresponding pins.  Then delete it, leaving only one tag." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Merge Tags", @"Rename Imported Tags", nil];

            [alert show];

        }
 
    }    
    
}


-(void)checkToSeeIfNewDataAndImportAlertViewResponseTree:(NSString *)response
{
    
    if([response isEqualToString:@"Merge Tags"]){
        
        appDel.tagsToImport = nonDups;
        [pointerToMainViewController importNewData];
        
    }else if([response isEqualToString:@"Rename Imported Tags"]){
        
        // for all tags in import
        for(MCTag *tag in appDel.tagsToImport){

            // if this is not the import tag prev add
            if(![[NSString stringWithFormat:@"<%@>", dateStamp] isEqualToString:tag.tagName])
            {
                NSString *newName = [NSString stringWithFormat:@"%@ ... %@>", 
                                     [tag.tagName substringToIndex:[tag.tagName length]-1], 
                                     dateStamp];
                
                // change the corresponding tags attached to each location
                for(MCLocation *loc in appDel.locationsToImport){
                    
                    [loc editTagsAttachedToMCLocationObject_OldTagName:tag.tagName newTagName_orEmptyStringToDelete:newName];
                    
                }
                
                // change the tag in the master list of tags
                tag.tagName = newName;
                
            
            }
               

        }
        
        [pointerToMainViewController importNewData];
        
    }else if ([response isEqualToString:@"Cancel"]){
    
        // if cancel, then delete temporary data
        appDel.locationsToImport = nil;
        appDel.tagsToImport = nil;
    }
}

-(void)findDupsAndNonDups
{
    BOOL isDup; 
    
    for(MCTag *tag in appDel.tagsToImport){
    
            isDup = FALSE;
        
            for(MCTag *tag2 in [pointerToMainViewController returnListOfTags]){
        
                
                if([tag.tagName isEqualToString:tag2.tagName]){
                
                        isDup = TRUE;
                        break;
                    
                }
            }
    
        if(isDup){
        
            [dups addObject:tag];
            
        }else{
        
            [nonDups addObject:tag];
        
        }
        
    }
}


#pragma mark Delegates

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    [self checkToSeeIfNewDataAndImportAlertViewResponseTree: [alertView buttonTitleAtIndex:buttonIndex]];
    
}

@end


