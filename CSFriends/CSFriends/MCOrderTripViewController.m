//
//  MCOrderTripViewController.m
//  CSFriends
//
//  Created by xcode on 1/16/14.
//  Copyright (c) 2014 xcode. All rights reserved.
//

#import "MCOrderTripViewController.h"
#import "MCLocation.h"
#import "UIViewController+ResizingForDifferentDevices.h"
#import "MCAppDelegate.h"

@interface MCOrderTripViewController ()

// from .h file
// @property MCTag *tagSelected;
// @property MCViewController *pointerToMainViewController;

  @property (strong, nonatomic) IBOutlet UITableView *tableView;
  @property NSMutableArray *listOfAllLocations;  // pointer to global data
  @property NSMutableArray *listOfTagsLocations;

  @property (strong, nonatomic) IBOutlet UILabel *title;
  @property (strong, nonatomic) IBOutlet UILabel *subTitle;
  @property (strong, nonatomic) IBOutlet UIButton *backButton;

  @property (strong, nonatomic) IBOutlet UIView *subviewBottomBar;
  @property (strong, nonatomic) IBOutlet UILabel *displayTripOnMapLabel;
  @property (strong, nonatomic) IBOutlet UISwitch *switch_displayTripOnMap;
  @property (strong, nonatomic) IBOutlet UILabel *labelEndPoint;

  @property (strong, nonatomic) IBOutlet UIButton *setEndPointButton;
  @property (strong, nonatomic) IBOutlet UIButton *moveUpButton; 
  @property (strong, nonatomic) IBOutlet UIButton *moveDownButton;
  @property (strong, nonatomic) IBOutlet UILabel *textLabel;



  -(void)positionScreenObjects;

  -(void)makeListOfFilteredLocationsForTag;
  -(MCTag *)hasTag:(MCLocation *)loc;
  -(void)sortListOfFilteredLocationsForTag;
  -(void)renumberListOfFilteredArraysAfterInitialSort;

  - (IBAction)setEndPointButtonPressed:(id)sender;
  - (IBAction)moveUpButtonPressed:(id)sender;
  - (IBAction)moveDownButtonPressed:(id)sender;
  - (IBAction)displayTripButtonPressed:(id)sender;
  - (void)moveUpOrDown:(int)toMoveUpPassMinusOne_toMoveDownPassPositiveOne;
  - (void)correctOutOfBoundsIndexNumbersStartingAtZeroNotLast:(int)toMoveUpPassMinusOne_toMoveDownPassPositiveOne arry:(NSMutableArray *)selectedLocations;

  -(void)saveTagsAndLocations;

@end

@implementation MCOrderTripViewController
  @synthesize tableView, moveDownButton, moveUpButton, listOfAllLocations, listOfTagsLocations, tagSelected, pointerToMainViewController, textLabel, title, backButton, displayTripOnMapLabel, switch_displayTripOnMap, delegate, subTitle, subviewBottomBar, setEndPointButton, labelEndPoint;


#pragma mark Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // basic setup
    title.text = [tagSelected.tagName substringWithRange:NSMakeRange(1, [tagSelected.tagName length] - 2)];
    [switch_displayTripOnMap setOn: tagSelected.displayTripLines];
    [self positionScreenObjects];
    
    if(tagSelected.finalDestination && ![tagSelected.finalDestination isEqualToString:@""]){
    
        labelEndPoint.text = [NSString stringWithFormat:@"After your trip, you will return to %@.", tagSelected.finalDestination];
        
    }else{
    
        labelEndPoint.text = [NSString stringWithFormat:@"This is a one way trip."];    
    }

    
    // setup table
    tableView.delegate = self;
    tableView.dataSource = self;
    
    listOfAllLocations = [pointerToMainViewController returnListOfAllLocations];
        
    [self makeListOfFilteredLocationsForTag];
    [self sortListOfFilteredLocationsForTag];
    [self renumberListOfFilteredArraysAfterInitialSort];
    
    // display view
    self.view.hidden = FALSE;
    
}

-(void)positionScreenObjects
{
    
    // change fonts
    [self changeFontSizeForButtonsAndLabels:[NSMutableArray arrayWithObjects:backButton, title, displayTripOnMapLabel, switch_displayTripOnMap, nil] fontSize:[pointerToMainViewController returnFontBig]scaleFactorToConvertSizesFromIPhoneToIPad:[pointerToMainViewController returnScaleFactor]];
     
    [self changeFontSizeForButtonsAndLabels:[NSMutableArray arrayWithObjects:setEndPointButton, moveDownButton, moveUpButton, textLabel, subTitle, nil] fontSize:[pointerToMainViewController returnFontNormal]scaleFactorToConvertSizesFromIPhoneToIPad:[pointerToMainViewController returnScaleFactor]];
     
    [self changeFontSizeForButtonsAndLabels:[NSMutableArray arrayWithObjects: labelEndPoint, nil] fontSize:[pointerToMainViewController returnFontNormal] scaleFactorToConvertSizesFromIPhoneToIPad:[pointerToMainViewController returnScaleFactor]];
    
    // space evenly 
    [self spaceObjectsEvenlyAlongXAxis:[NSMutableArray arrayWithObjects:setEndPointButton, moveDownButton, moveUpButton, textLabel, nil]];
    [self spaceObjectsEvenlyAlongXAxis:[NSMutableArray arrayWithObjects:title, nil]];
    [self spaceObjectsEvenlyAlongXAxis:[NSMutableArray arrayWithObjects:subTitle, nil]];
    [self spaceObjectsEvenlyAlongXAxis:[NSMutableArray arrayWithObjects:displayTripOnMapLabel, switch_displayTripOnMap, nil]];
    [self spaceObjectsEvenlyAlongXAxis:[NSMutableArray arrayWithObjects: labelEndPoint, nil]];
    
     // set subview position
    subviewBottomBar.frame = CGRectMake(0, self.view.frame.size.height - (subviewBottomBar.frame.size.height + 10) * [pointerToMainViewController returnScaleFactor], self.view.frame.size.width, (subviewBottomBar.frame.size.height + 10) * [pointerToMainViewController returnScaleFactor]);
    
     // add line
     UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, subviewBottomBar.frame.origin.y + labelEndPoint.frame.origin.y + labelEndPoint.frame.size.height * 1.4, self.view.frame.size.width, 1)];
     line.backgroundColor = [UIColor lightGrayColor];
     [self.view addSubview:line];
    
    // resize label input so that text won't get clipped on update and recenter
    labelEndPoint.frame = CGRectMake(labelEndPoint.frame.origin.x, labelEndPoint.frame.origin.y, self.view.frame.size.width, labelEndPoint.frame.size.height);
    labelEndPoint.center = CGPointMake(self.view.frame.size.width/2, labelEndPoint.frame.origin.y);  
    
    // recenter switchButton
    switch_displayTripOnMap.center = CGPointMake(switch_displayTripOnMap.center.x, displayTripOnMapLabel.center.y);
    
    // set tableview frame
    tableView.frame = CGRectMake(0, tableView.frame.origin.y * [pointerToMainViewController returnScaleFactor], self.view.frame.size.width, subviewBottomBar.frame.origin.y - tableView.frame.origin.y * [pointerToMainViewController returnScaleFactor]);
    

}


#pragma mark Display Info

-(void)makeListOfFilteredLocationsForTag
{
    // filter locations so displays only locations with selected tag 
    // (ie, the tag is in the attached array of tags)
    
    listOfTagsLocations = [NSMutableArray new];

    for(MCLocation *loc in listOfAllLocations){
    
        // does the loc have the desired tag and what is the pointer to the tag?
        MCTag *tag = [self hasTag:loc];
        
        if(tag){
        
            loc.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt = tag;
            
            [listOfTagsLocations addObject:loc];
            loc.displayPin = TRUE;  // unselect pin
        
        }
 
    }
        // debug
        //[self nslogLocations:@"xxxx entry xxxxx"]; 
}

-(MCTag *)hasTag:(MCLocation *)loc
{
    for(MCTag *tag in loc.tags){
        
        if ([tag.tagName isEqualToString:tagSelected.tagName]){
            
            return tag; }
        
    }
    
    return nil;
}

-(void)sortListOfFilteredLocationsForTag
{

    // sort locations
    [listOfTagsLocations sortUsingComparator:^NSComparisonResult(MCLocation *obj1, MCLocation *obj2) {

        if([(MCTag *)obj1.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt positionInTripAndArray]<
           [(MCTag *)obj2.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt positionInTripAndArray]){

            return -1;
            
        }else if ([(MCTag *)obj1.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt positionInTripAndArray]>
                  [(MCTag *)obj2.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt positionInTripAndArray]){
    
            return 1;
            
        }else{

            if(obj1.coordinate.longitude < obj2.coordinate.longitude){
            
                return 1;
                
            }else{
            
                return -1;
                
            }
        
        }
            
    }];

}

-(void)renumberListOfFilteredArraysAfterInitialSort
{
    // new tags start with a position == 1000
    // renumber one by one, you just put them in order
    // so their position corresponds to their index number
    
    int counter = 0;
    
    for(MCLocation *loc in listOfTagsLocations){

        loc.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt.positionInTripAndArray = counter;
        counter++;
  
    }

}


#pragma mark REORDER

- (IBAction)moveUpButtonPressed:(id)sender 
{
    
    [self moveUpOrDown:-1];
    
}

- (IBAction)moveDownButtonPressed:(id)sender {
    
    [self moveUpOrDown:1];
}


-(void)moveUpOrDown:(int)toMoveUpPassMinusOne_toMoveDownPassPositiveOne
{
    // OVERVIEW
    // to move objects up and down, change the index number, and then sort
    // the index number is stored in MCLocation.Tags[selected].positionInTripAndArray
    // or just location.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt.positionInTripAndArray
    
    // STRATEGY
    // a) get all selected locations
    // b) adjust index (eg. index = index - 1)
    // c) recombine list of select locations and list of not selected locations
    //    ie, if index position not used in selectedLocationList then put next notSelectedLocation there
    
    
    NSMutableArray *selectedLocations = [NSMutableArray new];
    NSMutableArray *notSelectedLocations = [NSMutableArray new];
    
    // divide locations into list of selected locations and unselected locations
    for(MCLocation *loc in listOfTagsLocations){
        
        if(loc.displayPin){
            
            // if displayPin = TRUE, it means not selected
            [notSelectedLocations addObject:loc];
            
        }else{
            
            [selectedLocations addObject:loc];
            
        }    
    }
    
    // if no selectedLocations quit
    if([selectedLocations count] == 0){ return; }

    
    // adjust index of selected locations + or - 1
    for(MCLocation *loc in selectedLocations){
        
        loc.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt.positionInTripAndArray += toMoveUpPassMinusOne_toMoveDownPassPositiveOne;
        
    }
    
    // if index has value of -1 or maxIndex = last + 1, make correction
    // if correction results in duplicate index number, correct
    [self  correctOutOfBoundsIndexNumbersStartingAtZeroNotLast:toMoveUpPassMinusOne_toMoveDownPassPositiveOne arry:selectedLocations];
    
    
    // combine
    
    int indexOfNotSelectedLocations = 0;
    int indexOfSelectedLocations = 0;
    
    for(int counter = 0; counter < [listOfTagsLocations count] ; counter ++){
        
        // if there are any selectedLocations left then
        // if position not taken, give to notSelected
        if(indexOfSelectedLocations != [selectedLocations count] && [[selectedLocations[indexOfSelectedLocations] tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt]positionInTripAndArray] == counter) {
            
            indexOfSelectedLocations++;
            
        }else{
            
            [notSelectedLocations[indexOfNotSelectedLocations] tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt].positionInTripAndArray = counter;
            indexOfNotSelectedLocations++;
            
        }
        
    }

    
    // sort and display
    [self sortListOfFilteredLocationsForTag];
    [tableView reloadData];
    
}

- (void)correctOutOfBoundsIndexNumbersStartingAtZeroNotLast:(int)toMoveUpPassMinusOne_toMoveDownPassPositiveOne arry:(NSMutableArray *)selectedLocations
{
    
    int startAt;
    int disallowedValue;
    int increment;
    
    if(toMoveUpPassMinusOne_toMoveDownPassPositiveOne == -1){
        
        // iterate from zero to last
        startAt = 0;
        increment = 1;
        
        // position cannot be -1
        disallowedValue = -1;
        
    }else{
        
        // iterate from last to zero
        startAt = (int)[selectedLocations count] - 1;
        increment = -1;
        
        // position/index values cannot be > count - 1
        disallowedValue = (int)[listOfTagsLocations count];
    }
    
    // increment thru values of selectedLocations
    for(int i = startAt; i < [selectedLocations count] && i >= 0 ; i += increment){
        
        MCTag *ptr = [selectedLocations[i] tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt];
        
        // see if disallowed value
        if(ptr.positionInTripAndArray == disallowedValue){
            
            // if disallowed, change
            ptr.positionInTripAndArray = disallowedValue + increment;
            // this number is the new disallowed value
            disallowedValue = ptr.positionInTripAndArray;
            
        }else{
            
            // if no illegal value, then exit
            break;
            
        }
        
    }
}


#pragma mark Other Buttons

- (IBAction)displayTripButtonPressed:(id)sender {
    
    tagSelected.displayTripLines = switch_displayTripOnMap.on;
}


- (IBAction)setEndPointButtonPressed:(id)sender {
    
    // set end point = first selected location
    for(MCLocation *loc in listOfTagsLocations){
        
        if(!loc.displayPin){       //ie,  if selected

            labelEndPoint.text = [NSString stringWithFormat:@"After your trip, you will return to %@.", loc.title]; 
            tagSelected.finalDestination = loc.title;
            return;
        
        }
    }
    
    labelEndPoint.text = [NSString stringWithFormat:@"This is a one way trip."]; 
    tagSelected.finalDestination = @"";
}


#pragma mark tableView

-(UITableViewCell *)tableView:(UITableView *)tableViewX cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aaa"];
    
    if(!cell){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"aaa"];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [pointerToMainViewController returnFontBig];
        cell.detailTextLabel.font = [pointerToMainViewController returnFontSmall];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // cell height set in heightForRowAtIndex
    }
    
    // get MCLocation object
    MCLocation *loc = [listOfTagsLocations objectAtIndex:indexPath.row];
    
    // get photo
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSURL *documentDirectory = [[fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSData *imageData = [NSData dataWithContentsOfURL:[documentDirectory URLByAppendingPathComponent:loc.imageLocation]];
    
    cell.imageView.image = [UIImage imageWithData: imageData];
    
    if(!cell.imageView.image){
        cell.imageView.image = [UIImage imageNamed:@"person"];}
    
    // get text
    NSString *spacing = [NSString stringWithFormat:@"                  "];
    if ([loc.title length] <= [spacing length]){
        spacing = [spacing substringFromIndex:[loc.title length]];
    }else{
        spacing = @" "; }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@%@", loc.title, spacing, loc.country];
    
    // NOT CURRENTLY DISPLAYING CELL DETAIL (code below)    
    //    NSString *str = loc.location;
    //    if(![loc.notes isEqualToString:@""]) { 
    //        str = [NSString stringWithFormat:@"%@. (%@)",str, loc.notes];}
    //    cell.detailTextLabel.text = str;
    
    // add checkmark
    if(loc.displayPin) {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }else{
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;   
        
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableViewX didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // a) toggle displayPin/isNotSelected property of MCLocation
    // b) reload table
    // c) on reload add checkmark by setting accessory type
    
    MCLocation *loc = [listOfTagsLocations objectAtIndex: indexPath.row]; 
    loc.displayPin = (loc.displayPin + 1) % 2; 

    [tableView reloadData];        
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [listOfTagsLocations count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 2 * [pointerToMainViewController returnFontBig].lineHeight;
    
}


#pragma mark Segue & Save

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    [self saveTagsAndLocations];
    
    //debug 
    //[self nslogLocations:@"xxx exit xxx"];
}

-(void)saveTagsAndLocations
{
    // the SelectTagViewController is responsible for working with tags
    // the main ViewController is responsible for working with locations
    // (yes, it may have been better breaking it out into objects, but 
    //  it started out as a very small program)
    
    [delegate saveListOfTags];
    [pointerToMainViewController savePins];

}


// xxxxxxxxxxx
-(void)nslogLocations:(NSString *)text
{

    NSLog(@"%@", text);
    for(MCLocation *loc in listOfTagsLocations){
    
            NSLog(@"%i %@", loc.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt.positionInTripAndArray, loc.title );
    }
}


#pragma mark App Activated / Add Observer

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // add Observer - want to be able to respond to application events, eg, incoming data
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector( appActivated: )
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];    
}

- (void)appActivated:(NSNotification *)note
{
    
    MCAppDelegate *appDel = [[UIApplication sharedApplication] delegate]; 
    
    if(appDel.locationsToImport || appDel.tagsToImport){
        
        // Notify User Data Received
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data Received" message:@"Data import will commence upon return to main screen." delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
}



@end

