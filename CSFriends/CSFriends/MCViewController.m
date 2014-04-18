//
//  MCViewController.m
//  CSFriends
//
//  Created by xcode on 11/27/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import <math.h>
#import <AVFoundation/AVFoundation.h>

#import "MCViewController.h"
#import "MCDetailViewController.h"
#import "MCSelectTagViewController.h"
#import "MCAppDelegate.h"
//#import "MCAddPinViewController.h"        // in .h file

#import "UIViewController+ResizingForDifferentDevices.h"

#import "MCLocation.h"
#import "MCAnnotationView.h"
#import "MCTag.h"
#import "MCArchiveFileManager.h"

@interface MCViewController ()

  @property (strong, nonatomic) IBOutlet MKMapView *mapView;
  @property (strong, nonatomic) IBOutlet UITableView *table;

  // arrays
  @property NSMutableArray *listOfAllLocations;
  @property NSMutableArray *listOfFilteredLocations;
  @property NSMutableArray *listOfLocationsOnScreen;
  @property NSMutableArray *listOfTags;

  @property NSMutableArray *selectedPinsForSegue;  // not actively maintained (ie, don't just call it)
  @property NSMutableArray *mapViewOverlays;

  // views and buttons
  @property (strong, nonatomic) IBOutlet UIView *menu_tableIsFullScreen;
  @property (strong, nonatomic) IBOutlet UIView *menu_moveToRegion;
  @property (strong, nonatomic) IBOutlet UIView *menu_mainMenu;

  @property (strong, nonatomic) IBOutlet UIButton *filterByTagButton;
  @property (strong, nonatomic) IBOutlet UIButton *addFriendsButton;
  @property (strong, nonatomic) IBOutlet UIButton *viewSelection;
  @property (strong, nonatomic) IBOutlet UIButton *optionsButton;
  @property (strong, nonatomic) IBOutlet UIButton *backButtonForFullScreenMenu;

  // for going on a tour
  @property MCAnnotationView *tour_NameAndImage;
  @property UILabel *tour_LocationLabel;

  @property UIButton *fullScreenViewToBlockInputs;
  @property BOOL terminateAutomatedTour;

  @property AVAudioPlayer *musicAndPlayer;
  
  // action sheets
  @property UIActionSheet *actionSheetPinOptions;
  @property UIActionSheet *actionSheetTour;

  // fonts
  @property UIFont *fontBig, *fontNormal, *fontSmall;
  @property float scaleFactorToConvertSizesFromIPhoneToIPad;

  // misc
  @property BOOL screenAndPositionLayoutCompleted;
  @property (strong, nonatomic) IBOutlet UILabel *labelShowingTagsSelected;
  @property BOOL showImageNotPin;
  @property NSMutableArray *colorsForOverlay;      // to pass parameter to mapView delegate
  @property MCArchiveFileManager *archiveFM;       // to prevent early release of object before delegate call

  // setup                                  
  -(void)setup;
  -(void)loadData_fileNameForPinPlistData:(NSString *)fileNamePins fileNameForTagPlistData:(NSString *)fileNameTags;
  -(void)intro_delay:(int)delayBeforeBegin;
  -(void)setScreenPositionsAndFonts;
     -(void)moveMajorScreenElementsToStartingPositions;
     -(void)changeFontSize;
     -(void)spaceMenuItems:(UIView *)view;

  // update
  -(void)putPinsOnMap;
  -(void)filterPinsAndDisplay;
  -(void)updateTableWhenMapRegionChanges;
  -(void)sortLocations:(NSMutableArray *)arry;
  -(void)refreshMapWithListOfEditedPinsOrNilForAll:(NSMutableArray *)arry;

  // buttons
  - (IBAction)europeButtonPressed:(id)sender;
  - (IBAction)asiaButtonPressed:(id)sender;
  - (IBAction)northAmericaButtonPressed:(id)sender;
  - (IBAction)southAmericaButtonPressed:(id)sender;
  - (IBAction)africaButtonPressed:(id)sender;

  - (IBAction)viewFullListButtonPressed:(id)sender;
  - (IBAction)tourRegion:(id)sender;
  - (IBAction)swipeLeft:(id)sender;   // calls viewFullList
  - (IBAction)swipeRight:(id)sender;  // hides viewFullList
  - (IBAction)pinOptionButtonPressed:(id)sender;

  // Full Screen Buttons
  - (IBAction)backButtonPressed:(id)sender;
  - (IBAction)selectAllButtonPressed:(id)sender;
  - (IBAction)deselectAllButtonPressed:(id)sender;
  - (IBAction)viewSelectionButtonPressed:(id)sender;
  - (IBAction)deleteSelectionButtonPressed:(id)sender;

  // build overlay
  -(void)makeMapPolygonForTags;
  -(void)displayTripLinesOverlay;
  -(NSMutableArray *)makeListOfFilteredLocationsForTag:(MCTag *)tag;
  -(MCTag *)searchForTag:(MCTag *)searchFor inLocationObject:(MCLocation *)loc;

  // automated tour 
  - (void)tourRegionSetup;
  - (void)tourWorldSetup;
  - (void)tourTripSetup:(MCTag *)trip;
  - (void)tourSetup2:(NSMutableArray *)arry;
  - (void)nextStepOnMapWithArray:(NSMutableArray *)arry;
  - (void)zoomInOnLocation:(MCLocation *)loc;
  - (void)zoomOutFromLocation:(NSMutableArray *)arry;
  - (IBAction)fullScreenToBlockInputsRecievesInput:(id)sender;
  - (void)terminateAutomatedProcess;

  // smoothing out transitions, little interface features, etc.
  -(void)makeScreenObjectsVisable;
  -(void)makeScreenObjectsInvisable;
  -(void)fadeMenus;
  -(void)unfadeMenus;

  // File Management
  //-(void)savePins;      // in .h file
  -(void)deletePins;

@end


// UPGRADES:
// allow to pull data from webserver
// Map: allow to change to satallite
// Tour: add option that mixes slide show with the tour
// Tour: add airplane flying from one point to the next with line following behind (overlay may be expensive)
// Tour: consider breaking out the tour as an object that can be reused (it is tightly integrated with mapview and rest of program, so it might be tricky; note: mapView cannot be subclassed)
//  [initially this was just a small project, so I put a lot of functionality within the view controllers, the tag controller takes care of updating the list of tags, for instance (tags and locations, of course, are their own classes); it may be worth considering breaking out this functionality as classes of their own (subclass NSMutableArray and move the functionality there), but probably not worth the effort, and delegate methods often have to go back through the controller (MVC)]

// LITTLE THINGS:
// add exit button to detail page so don't have to scroll thru (or change the last "next" to exit)???
// detail label names should be changed???
// overlay didn't disappear when deleted tags (it is a caching thing or not called) or did when not supposed to??? ahhh
// option for delete all pins for trip (vs just the label)?

// KNOWN ISSUES:

// if change name/title of a location which is marked as the final destination, it will not update the final destination (not a big deal, but would be nice to address)

// displaying photos on the map is problematic: (removed from beta release)
// -without reuse ids, get memory issues
// -if have reuse for each location, see improvement because not making the same one twice, but still have potential memory issues - could turn off photo on memory warning) 
// -if use reuse location objects, mapKit not reusing properly (I can reset the values, but mapKit has it cached or something, maybe a problem with subclassing?) [mapkit treats annotations like a list in a table, when the top field becomes free all values are moved up one, the problem is that the locations are no longer in the correct position

// check, I think that sometimes overlays don't refresh (at least in sim), probably mapKit caching and memory

// map kit provides no animation on long animations across globe (see more often on device than simulator), a guess is that it has to do with memory and caching

// in China, map kit given different data stream (showing Tiawan as a province of China, et. al), resulting in CGBitmapContextCreate error, but does not crash app; online discussion boards concerning are in Chinese

@implementation MCViewController
  @synthesize mapView, listOfFilteredLocations, listOfAllLocations, listOfLocationsOnScreen, table, fullScreenViewToBlockInputs, terminateAutomatedTour, listOfTags, addFriendsButton, filterByTagButton, labelShowingTagsSelected, selectedPinsForSegue, menu_tableIsFullScreen, menu_moveToRegion, menu_mainMenu, viewSelection, showImageNotPin, tour_NameAndImage, tour_LocationLabel, optionsButton, screenAndPositionLayoutCompleted, fontBig, fontNormal, fontSmall, backButtonForFullScreenMenu, scaleFactorToConvertSizesFromIPhoneToIPad, musicAndPlayer, mapViewOverlays, colorsForOverlay, actionSheetPinOptions, actionSheetTour, archiveFM;


#pragma mark Setup, Filter, & Display

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MCArchiveFileManager *aFM = [MCArchiveFileManager new];
    [aFM cleanUpOldFiles];
    
    [self setup];
    [self intro_delay: 0];
  
  // viewDidAppear will run setScreenPositionsAndFonts
    
  // Intro Tour will finish setup after completion:     
  
  //[self loadData_fileNameForPinPlistData:@"csfriends.plist" fileNameForTagPlistData:@"listOfTags.plist"];
  //[self checkToSeeIfNewDataAndImport];
  //[self filterPinsAndDisplay];
  //[self makeMapPolygonForTags];
  //[self updateTableWhenMapRegionChanges];             
  //[self terminateAutomatedProcess];   // ie the tour
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
    if(!screenAndPositionLayoutCompleted) {

        // just want to run when open file
        [self setScreenPositionsAndFonts];

    }else{

        // when coming back from an unwind segue
        [self refreshAll];
        
    }

}

-(void)refreshAll
{

    [self checkToSeeIfNewDataAndImport];         // if new data, will present tag controller           
    [self filterPinsAndDisplay];
    [self updateTableWhenMapRegionChanges];
    [self makeMapPolygonForTags];
    [self makeScreenObjectsVisable];             // to avoid flicker, when updating
}

-(void)setup
{
    // set delegates
    mapView.delegate = self;
    table.delegate = self;
    table.dataSource = self;
    
    // initialize arrays
    listOfAllLocations = [NSMutableArray new];
    listOfFilteredLocations = [NSMutableArray new];
    listOfLocationsOnScreen = [NSMutableArray new];
    
    selectedPinsForSegue = [NSMutableArray new];
    listOfTags = [NSMutableArray new];
    mapViewOverlays = [NSMutableArray new];
    
    // initialize fonts resize UIViews (containers)  
    if(self.view.frame.size.width < 700.0 ){

        // it is a phone
        fontSmall = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
        fontNormal = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
        fontBig = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        scaleFactorToConvertSizesFromIPhoneToIPad = 1.0;
        
    }else{
        
        // it is a iPad
        fontSmall = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        fontNormal = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
        fontBig = [UIFont fontWithName:@"HelveticaNeue-Light" size:26.0];
        scaleFactorToConvertSizesFromIPhoneToIPad = 20.0/12;
        // note: remember to add dec place, or it will treat as an int and round, even though it is a float
        
    }

    // turn off the ability to rotate map and set pinToggle to display pin
    mapView.rotateEnabled = FALSE;
    showImageNotPin = FALSE;
    
    // hide table to full screen menu
    menu_tableIsFullScreen.hidden = TRUE;
    backButtonForFullScreenMenu.hidden = TRUE;
    
    // create bubble to display info during tour (use existing annotation format to create)
    MCLocation *loc = [[MCLocation alloc] initWithTitle:@"title" coordinate:CLLocationCoordinate2DMake(0.0,0.0) location:nil country:nil notes:nil imageLocation:@"person" tags:nil];
    tour_NameAndImage = [[MCAnnotationView alloc] initFromLocationToDisplay:loc font: fontBig scaleFactor:scaleFactorToConvertSizesFromIPhoneToIPad];
    
    tour_NameAndImage.hidden = TRUE;
    [self.view addSubview:(UIView *)tour_NameAndImage];
    [self.view bringSubviewToFront:tour_NameAndImage];
    
    // add additional label for during tour
    tour_LocationLabel = [UILabel new];
    
    tour_LocationLabel.backgroundColor = [UIColor clearColor];
    tour_LocationLabel.font = fontBig;
    tour_LocationLabel.textColor = [UIColor blackColor];
    tour_LocationLabel.textAlignment = NSTextAlignmentCenter;
    
    tour_LocationLabel.hidden = true;
    [self.view addSubview:tour_LocationLabel];

    // create overlay to block inputs when desired
    fullScreenViewToBlockInputs = [[UIButton alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height)];
    fullScreenViewToBlockInputs.backgroundColor = [UIColor clearColor];
    fullScreenViewToBlockInputs.hidden = TRUE;    
    [fullScreenViewToBlockInputs addTarget:self action:@selector(terminateAutomatedProcess) forControlEvents:UIControlEventAllTouchEvents];
    [self.view addSubview:fullScreenViewToBlockInputs];
    [self.view bringSubviewToFront:fullScreenViewToBlockInputs];
    
}


-(void)loadData_fileNameForPinPlistData:(NSString *)fileNamePins fileNameForTagPlistData:(NSString *)fileNameTags
{
    // LOCATIONS: 
    // access plist and build listOfAllLocations
    
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSURL *documentDirectory = [[fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSArray * loadedData = [NSArray arrayWithContentsOfURL:[documentDirectory URLByAppendingPathComponent:@"csfriends.plist"] ];
    
    // convert data back into objects (each object is a dictionary)
    for(id z in loadedData)
    {
        MCLocation *pinToAdd = [[MCLocation alloc] initFromDictionary:z];
        [listOfAllLocations addObject:pinToAdd];
    }
    

    // TAGS: 
    // load tags and build listOfTags array
    NSMutableArray *arry = [NSArray arrayWithContentsOfURL:[documentDirectory URLByAppendingPathComponent:@"listOfTags.plist"] ];

    for(NSDictionary *z in arry) {
        
        // convert dictionary to object and add to listOfTags
        [listOfTags addObject: [[MCTag alloc]initFromDictionary:z]];       
    }

    // IMAGES: 
    // image location is stored in location and will be retrived when needed
    
    
    // set initialization complete
    screenAndPositionLayoutCompleted = TRUE;
    
}

-(void)checkToSeeIfNewDataAndImport
{
    archiveFM = [MCArchiveFileManager new];
    [archiveFM checkToSeeIfNewDataAndPrepareForImport:self];
}

-(void)importNewData  // called by archiveFM, when checkToSeeIfNewDataAndPrepareForImport complete
{
    
    MCAppDelegate *appDel = [[UIApplication sharedApplication] delegate];
    
    // add new locations to listOfAllLocations, and tags to listOfTags
    [listOfAllLocations addObjectsFromArray: appDel.locationsToImport];
    [listOfTags addObjectsFromArray: appDel.tagsToImport];
    
    // delete temp location and tag data
    appDel.locationsToImport = nil;
    appDel.tagsToImport = nil;
    
    // manually save listOfAllLocations to hard drive
    [self savePins];
    
    // but will take the lazy approach to saving the list of tags and updating
    //   MCViewController properties to reflect the new data
    // we open tag view controller letting the user select pins (eleminating a source of possible confusion)
    // when exit tagViewController, it will save the list of tags and run viewDidAppear
    //   which will rebuild everything else from the ground up
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data Import Complete" message:@"Before returning to the main screen, select the tags you wish to view.\n\nPlease note that all imported pins have been given a tag showing you the date they were imported.  This alows you to easily locate your imported pins.  After you are done organizing your new pins, you may wish to delete this tag." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
    [self performSegueWithIdentifier:@"toSelectTagViewController" sender:filterByTagButton];
    
}

-(void)filterPinsAndDisplay
{

    // remove all objects from list of filtered pins and all data from map view
    [mapView removeAnnotations:listOfFilteredLocations];
    [listOfFilteredLocations removeAllObjects];
    
    
    // filter list of locations using tags and store in array (if loc has any of the tags, keep it)
    
    // check list of tags and make list which ones are wanted
    NSMutableArray *listOfSelectedTags = [NSMutableArray new];
    
    for(MCTag *z in listOfTags){
        
        if(z.selected){ [listOfSelectedTags addObject:z];}
        
    }
    
    // if no tags selected, show all
    if([listOfSelectedTags count] == 0){
    
        labelShowingTagsSelected.text = @"";
        
        for(MCLocation *z in listOfAllLocations){
            
            [listOfFilteredLocations addObject:z];
            
        }
        
    }else{
    
        // for each selected pin, look at each of its tags and see if in master list
        for(MCLocation *checkThisPin in listOfAllLocations){

            if([self checkToSeeIfPinMeetsFilterCriteria:checkThisPin listOfSelectedTags:listOfSelectedTags]){
                        
                [listOfFilteredLocations addObject:checkThisPin];
            
            }
    
        }
        
        // update labelShowingTagsSelected in mainscreen
        NSString *str = [NSString stringWithFormat:@"Tags:"];
        
        for(MCTag *z in listOfSelectedTags){
            str = [NSString stringWithFormat:@"%@ %@", str, z.tagName];
        }
            
        labelShowingTagsSelected.text = str;
    }
    
    // update map
    [self putPinsOnMap];
    
}

-(MCTag *)checkToSeeIfPinMeetsFilterCriteria:(MCLocation *)checkThisPin listOfSelectedTags:(NSMutableArray *)listOfSelectedTags
{

    for(MCTag *checkThisTag in checkThisPin.tags) {
            
            // check to see if it is in the listOfTags
            for(MCTag *requiredTag in listOfSelectedTags){
        
                if([checkThisTag.tagName isEqual: requiredTag.tagName]){ return checkThisTag;}
            }
        
    }
    
    return nil;

}

-(void)putPinsOnMap
{

    for(MCLocation *z in listOfFilteredLocations) {

        [self.mapView addAnnotation:z];
    }
    
    [mapView reloadInputViews];

}


-(void)togglePin:(MCLocation *)loc      
{
    loc.displayPin = (loc.displayPin + 1) % 2; 
}


#pragma mark App Activated / Add Observer 

// upon notification that app reactivated runs viewDidAppear
- (void)appActivated:(NSNotification *)note
{

    // this will be called both when app is started and when activated
    // don't want it to run viewDidAppear on start

    if(screenAndPositionLayoutCompleted){
        
        [self viewDidAppear:YES];
    }
    
    return;
    
}

- (void)appDeActivated:(NSNotification *)note
{
    
    [musicAndPlayer stop];  
    
        // note: fadeMusic (change vol) won't work and loose ability to control it when app reactivated (maybe loses pointer, not sure, but don't have time to play with)
    
}

// add observer
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // add Observer - want to be able to respond to application events, eg, incoming data
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector( appActivated: )
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil]; 
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector( appDeActivated: )
                                                 name: UIApplicationWillResignActiveNotification
                                               object: nil]; 
}

// remove observer
- (void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
    
}


#pragma mark Intro Tour

-(void)intro_delay:(int)delayBeforeBegin  // eg, if want to initiate another action first
{

    [self playMusic];
    
    terminateAutomatedTour = FALSE;
    fullScreenViewToBlockInputs.hidden = FALSE;
    [self fadeMenus];
    
    NSMutableArray *arryOfSelectors = @[@"northAmericaButtonPressed:",@"africaButtonPressed:", @"europeButtonPressed:", @"asiaButtonPressed:"].mutableCopy;
    
    [self performSelector:@selector(introB:) withObject:arryOfSelectors afterDelay:delayBeforeBegin];
    
}

-(void)introB: (NSMutableArray *)arryOfSelectors
{
    
    if(terminateAutomatedTour){
        
        [self exitIntroTour];
        return;
    }
    
    SEL selectorX = NSSelectorFromString( [arryOfSelectors objectAtIndex: 0]);
    [arryOfSelectors removeObjectAtIndex: 0];
    [self performSelector: selectorX withObject:arryOfSelectors afterDelay:0];
    
    if([arryOfSelectors count] == 0){
        
        [self performSelector:@selector(exitIntroTour) withObject:arryOfSelectors afterDelay:1.6]; 
        return;
        
    }else{
        
        [self performSelector:@selector(introB:) withObject:arryOfSelectors afterDelay:1.5]; 
    }
}

-(void)exitIntroTour
{
    if(!screenAndPositionLayoutCompleted){
        
        [self loadData_fileNameForPinPlistData:@"csfriends.plist" fileNameForTagPlistData:@"listOfTags.plist"];

    }
  
    [self checkToSeeIfNewDataAndImport];   
    [self filterPinsAndDisplay];
    [self makeMapPolygonForTags];
    [self updateTableWhenMapRegionChanges];
    [self terminateAutomatedProcess]; 
}


#pragma mark Setup Screen Positions And Fonts

-(void)setScreenPositionsAndFonts { 

    [self moveMajorScreenElementsToStartingPositions];
    [self changeFontSize];

    [self spaceMenuItems: menu_moveToRegion];
    [self spaceMenuItems: menu_mainMenu];
    [self spaceMenuItems: menu_tableIsFullScreen];
    
        
    [self makeScreenObjectsVisable];  // it is easier to conceputalize and design using the storyboard, but it is necessary to calcuate positioning manually, so all screen objects are hidden (set in storyboard), and after position adjusted, they will be unhidden 

}


-(void)moveMajorScreenElementsToStartingPositions
{
    
    float screenWidth = self.view.frame.size.width;
    float screenHeight = self.view.frame.size.height;
    
    float regionsMenuBarHt = menu_moveToRegion.frame.size.height;
    float mainMenuBarHt = menu_mainMenu.frame.size.height;
    float fullScreenMenuBarHt = menu_tableIsFullScreen.frame.size.height;
    float labelForTagsHt = labelShowingTagsSelected.frame.size.height;

    // resize if iPad
    regionsMenuBarHt = regionsMenuBarHt * scaleFactorToConvertSizesFromIPhoneToIPad;
    mainMenuBarHt = mainMenuBarHt * scaleFactorToConvertSizesFromIPhoneToIPad;
    
    fullScreenMenuBarHt = fullScreenMenuBarHt * scaleFactorToConvertSizesFromIPhoneToIPad;
    labelForTagsHt = labelForTagsHt * scaleFactorToConvertSizesFromIPhoneToIPad;
        

    menu_moveToRegion.frame = CGRectMake(0, 0, screenWidth, regionsMenuBarHt);
    mapView.frame = CGRectMake(0, regionsMenuBarHt, screenWidth, screenHeight * .60);
    menu_mainMenu.frame = CGRectMake(0, regionsMenuBarHt + mapView.frame.size.height, screenWidth, mainMenuBarHt);
    table.frame = CGRectMake(0, regionsMenuBarHt + mapView.frame.size.height + mainMenuBarHt, screenWidth, screenHeight  - regionsMenuBarHt - mapView.frame.size.height - mainMenuBarHt);
    
    menu_tableIsFullScreen.frame = CGRectMake(0, 0, screenWidth, fullScreenMenuBarHt);
    labelShowingTagsSelected.frame = CGRectMake(15, regionsMenuBarHt + mapView.frame.size.height - labelShowingTagsSelected.frame.size.height - 10, screenWidth - 30, labelForTagsHt);
    
    // tour positions/frame defined in displayTourHeaderInfo

}

-(void)changeFontSize
{
    NSMutableArray *listOfAllNormalTextItems = [NSMutableArray new];
    NSMutableArray *listOfBigTextItems = [NSMutableArray new];
    
    // add items to array
    [listOfAllNormalTextItems addObjectsFromArray: menu_moveToRegion.subviews];
    [listOfAllNormalTextItems addObjectsFromArray: labelShowingTagsSelected.subviews];
    [listOfAllNormalTextItems addObjectsFromArray: menu_mainMenu.subviews];
    [listOfAllNormalTextItems addObjectsFromArray: menu_tableIsFullScreen.subviews];
    [listOfAllNormalTextItems addObjectsFromArray: tour_LocationLabel.subviews];

    [listOfBigTextItems addObject:backButtonForFullScreenMenu];
    
    
    [self changeFontSizeForButtonsAndLabels:listOfAllNormalTextItems fontSize:fontNormal scaleFactorToConvertSizesFromIPhoneToIPad:scaleFactorToConvertSizesFromIPhoneToIPad];

    [self changeFontSizeForButtonsAndLabels:listOfBigTextItems fontSize:fontBig scaleFactorToConvertSizesFromIPhoneToIPad:scaleFactorToConvertSizesFromIPhoneToIPad];
    
}

-(void)spaceMenuItems:(UIView *)view
{

    [self spaceObjectsEvenlyAlongXAxis:[view subviews].mutableCopy]; 
    
}

-(void)makeScreenObjectsVisable
{
    [UIView animateWithDuration:.1 animations:^{

        menu_moveToRegion.hidden = FALSE;
        mapView.hidden = FALSE;
        menu_mainMenu.hidden = FALSE;
        table.hidden = FALSE;
        
        labelShowingTagsSelected.hidden = FALSE;         
        
    }];
    
}

-(void)makeScreenObjectsInvisable
{

    [UIView animateWithDuration:.1 animations:^{
        
        menu_moveToRegion.hidden = TRUE;
        mapView.hidden = TRUE;
        menu_mainMenu.hidden = TRUE;
        table.hidden = TRUE;
        
        labelShowingTagsSelected.hidden = TRUE;        
        
    }];

}


#pragma mark Buttons - MapView
// for "Tour" button, see Tour Region
// "Filters"  button opens View Controller (see storyboard)

- (IBAction)viewFullListButtonPressed:(id)sender {
    
    // show back button
    backButtonForFullScreenMenu.hidden = FALSE;
    
    // change height of table
    table.frame = CGRectMake(table.frame.origin.x, table.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - menu_tableIsFullScreen.frame.size.height);
    
    // move up
    [UIView animateWithDuration:.7 animations:^{
        
        menu_tableIsFullScreen.hidden = FALSE;
        table.frame = CGRectMake(0, menu_tableIsFullScreen.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - menu_tableIsFullScreen.frame.size.height);
    }];
    
}

- (IBAction)swipeLeft:(id)sender {
    
    if(fullScreenViewToBlockInputs.hidden == FALSE){
        
        return;
    }
    
    if(menu_tableIsFullScreen.hidden){
        
        [self viewFullListButtonPressed:nil];
        
    }else{
        
        [self viewSelectionButtonPressed:nil];
        
    }
    
}

- (IBAction)pinOptionButtonPressed:(id)sender {
    
   // actionSheetPinOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"MAP SELECTIONS:", @"Show name & photo.", @"Show red pin.",  @" ", @"SHARE LOCATIONS:", @"For Selected Tags", @"Selected Locations", @" ", @"About", nil];

   // removed MAP SELECTIONS: so always show red pin
   // to put functionality back in play, just un-comment-out above text
   // see known issues (top)
    
    actionSheetPinOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"SHARE PINS:", @"For Selected Tags", @"Selected Pins", @" ", @"About", nil];
    
    [actionSheetPinOptions showInView:self.view];

}

-(void)pinOptionsActionSheetResponseTree:(NSString *)buttonPressed
{

    if([buttonPressed isEqualToString:@"Show name & photo."]){
        
            showImageNotPin = TRUE;
            [self refreshMapWithListOfEditedPinsOrNilForAll: nil];
    
    }else if ([buttonPressed isEqualToString:@"Show red pin."]){

            showImageNotPin = FALSE;
            [self refreshMapWithListOfEditedPinsOrNilForAll: nil];
            
    }else if ([buttonPressed isEqualToString:@"For Selected Tags"]){
            
            [self shareTags];
        
    }else if ([buttonPressed isEqualToString:@"Selected Locations"]){
        
            [self shareLocs];
        
    }else if ([buttonPressed isEqualToString:@"About"]){
        
            [self about];
    
    }
    
}

-(void)about
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"About:" message:@"Created By: M.S. Cline\nMusic: Duelin' Daltons performed by Steve Dudash & Stephen Cline, 1980." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
}

-(void)shareTags
{
        
    //make list of selected tags 
    NSMutableArray *tagsToShare = [NSMutableArray new];
    
    for(MCTag *tag in listOfTags){
        if(tag.selected){ [tagsToShare addObject:tag];}
    }
    
    // if no tags selected, then give all tags
    if([tagsToShare count] == 0){ tagsToShare = listOfTags; }
    
    // notify user which tags exporting (they can cancel later)
    // notify user which locations exporting (they can cancel later)
    NSString *str = @"";
    NSString *rtn = @"";
    
    for(MCTag *tag2 in tagsToShare){
        
        str = [NSString stringWithFormat:@"%@%@%@", str, rtn, tag2.tagName ];
        rtn = @"\n";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exporting Pins With Selected Tags:" message:str delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
    
    // create archive file and active activity view / share screen
    MCArchiveFileManager *aFM = [[MCArchiveFileManager alloc] initAndCreateArchiveWithTags:(NSArray *)tagsToShare andTheirFilteredLocations:(NSArray *)listOfFilteredLocations];
    [aFM shareFileUsingActivityViewWithFileUrl:aFM.url withPointerToActiveViewController_NeededSoCanPresentActivityVC:self];
    
}

-(void)shareLocs
{

    // make list of all selected pins
    NSMutableArray *selectedPins = [NSMutableArray new];
    
    for(MCLocation *pin in listOfFilteredLocations){
        
        if(pin.displayPin == FALSE){ 
            
            [selectedPins addObject:pin]; }
        
    }            

    // if no selected pins, notify user and exit
    if([selectedPins count]==0){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Please make selection:" message:@"Before exporting data, please select the pins you would like to share." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
    }else{
        
        // notify user which locations exporting (they can cancel later)
        NSString *str = @"";
        NSString *rtn = @"";
        
        for(MCLocation *loc in selectedPins){
            
            str = [NSString stringWithFormat:@"%@%@%@", str, rtn, loc.title ];
            rtn = @"\n";
        }
        
        UIAlertView *alert2 = [[UIAlertView alloc] initWithTitle:@"Exporting Selected Locations:" message:str delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert2 show];
        
        // create archive file and active activity view / share screen
        MCArchiveFileManager *aFM = [[MCArchiveFileManager alloc] initAndCreateArchiveWithPins:(NSArray *)selectedPins];
        [aFM shareFileUsingActivityViewWithFileUrl:aFM.url withPointerToActiveViewController_NeededSoCanPresentActivityVC:self];
    }
    
}


#pragma mark Buttons - FullView

- (IBAction)backButtonPressed:(id)sender {
    
    [self refreshMapWithListOfEditedPinsOrNilForAll: nil];
    
    // change back to default screen view by moving/resizing table (which is hidding other elements)
    [UIView animateWithDuration:.7 animations:^{
        
        menu_tableIsFullScreen.hidden = TRUE;
        backButtonForFullScreenMenu.hidden = TRUE;
        table.frame = CGRectMake(0, menu_mainMenu.frame.size.height + mapView.frame.size.height + menu_moveToRegion.frame.size.height, table.frame.size.width, table.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        // change height of the table
        table.frame = CGRectMake(table.frame.origin.x, table.frame.origin.y, table.frame.size.width, self.view.frame.size.height - menu_moveToRegion.frame.size.height - menu_mainMenu.frame.size.height - mapView.frame.size.height);
        
    }];

}

- (IBAction)swipeRight:(id)sender {
    
    if(fullScreenViewToBlockInputs.hidden == FALSE){
        
        return;
    }
    
    [self backButtonPressed:nil];
}

- (IBAction)selectAllButtonPressed:(id)sender {
    
    // rem: "is selected" is equivalent to saying show image not pin
    // just need to change the MCLocation
    
    for(MCLocation *z in listOfLocationsOnScreen){
        
        z.displayPin = FALSE;
        
    }
    
    [table reloadData];
}

- (IBAction)deselectAllButtonPressed:(id)sender {
    
    for(MCLocation *z in listOfFilteredLocations){
        
        z.displayPin = TRUE;
        
    }
    
    [table reloadData];
    
}

- (IBAction)deleteSelectionButtonPressed:(id)sender {

    // get list of selected pins
        
    NSMutableArray *listOfPinsToDelete = [NSMutableArray new];
        
    for(MCLocation *loc in listOfFilteredLocations) {
            
            // if selected, then delete
            if(!loc.displayPin) {   
                
                [listOfPinsToDelete addObject:loc];
                
            }
    }
    
    
    // confirm deletion
    
    if([listOfPinsToDelete count] == 0 ){
    
        UIAlertView *alert2 = [[UIAlertView alloc]initWithTitle:@"Please select friends to delete." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert2 show];
        
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Delete Friends" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [alert show];
        
    }
    
}

-(void)deletePins
{
    
    // get list of selected pins to delete
    NSMutableArray *listOfPinsToDelete = [NSMutableArray new];
    
    for(MCLocation *loc in listOfFilteredLocations) {
        
        // if selected (ie, showing full image, not pin), then delete
        if(!loc.displayPin) {   
            
            [listOfPinsToDelete addObject:loc];
            
        }
    }
    
    
    // to update map, remove object and re-add list of ALL annotations
    [mapView removeAnnotations: listOfFilteredLocations];  
    
    
    // delete items from lists lists of locations to display
    [listOfAllLocations removeObjectsInArray:listOfPinsToDelete]; // master list
    [listOfFilteredLocations removeObjectsInArray:listOfPinsToDelete];  // so don't have to refilter
    
    
    // update map
    [mapView addAnnotations:listOfFilteredLocations];
    [mapView reloadInputViews];
    
    // update table
    [self updateTableWhenMapRegionChanges];
    
    // save list of pins (now without delete objects)
    [self savePins];
    
    // delete image
    for(MCLocation *loc in listOfPinsToDelete){
    
        if(![loc.imageLocation isEqualToString:@""]){
            
            NSFileManager *fileManger = [NSFileManager defaultManager];
            NSURL *documentDirectory = [[fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            documentDirectory = [documentDirectory URLByAppendingPathComponent:loc.imageLocation];
            
            [fileManger removeItemAtURL:documentDirectory error:nil];  // Apple recommends not checking for file existence first - in order to predicate behavior, but to deal with errors later
            
        }    
    }
    
}


#pragma mark AlertViews / Action Sheets
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   if([alertView.title isEqualToString:@"Delete Friends"]){
    
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                [self deletePins];
                break;            
        }
        
   } else { NSLog(@"passing thru alertView - no response required"); }
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    // if edit, nice to refactor with if(buttonTitle == ) throughout
    // - not as efficient, but would increase readibility 
    // - although code remains brittle: with indexes, if add or delete or reorder, code doesn't work
    //   with titles, if change, code doesn't work
    
    
    if(actionSheet == actionSheetTour){
        
        
        // make list of trips so can look up which index selected 
        
        NSMutableArray *selectedTrips = [NSMutableArray new];
        
        for(MCTag *trip in listOfTags){
            
            if(trip.selected && trip.displayTripLines){
                
                [selectedTrips addObject:trip];
            }
        }
        
        
        if(buttonIndex == 0){ 
            
            [self tourRegionSetup]; 
            
        } else if(buttonIndex == 1){    
            
            [self tourWorldSetup];          
            
        } else if (buttonIndex == [selectedTrips count] + 2){     
            
            // total number of buttons: hard coded buttons (2) + cancel button (1) + a button for each trip
            // the cancel button is the last one
            // for index number, subtract one
            
            return;
            
        } else {                                
            
            int indexOfTripInSelectedTags = (int)buttonIndex - 2;
            MCTag *tripToView = selectedTrips[indexOfTripInSelectedTags]; 
            [self tourTripSetup: tripToView];
        }
        
        
    // For Second Action Sheet    
    }else if(actionSheet == actionSheetPinOptions){

        [self pinOptionsActionSheetResponseTree:buttonTitle];
        
    }
    
}


#pragma mark Segue & Save

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    [self makeScreenObjectsInvisable];
    
    if(sender == filterByTagButton){
        
        MCSelectTagViewController *tagViewController = segue.destinationViewController;
        tagViewController.delegate = self;
        tagViewController.listOfTags = listOfTags;
        return;
        
    } 
  
    else if(sender == addFriendsButton) {
       
        // create true/deep copy of listOfTags to work with 
        NSMutableArray *copyOfListOfTags = [NSMutableArray new];
        for(MCTag *z in listOfTags){
            [copyOfListOfTags addObject:[[MCTag alloc]initWithTitle:z.tagName isSelected:FALSE]];}
        
        // set delegate, etc.
        MCAddPinViewController *addPinViewController = segue.destinationViewController;
        addPinViewController.pointerToMainViewController = self;
        addPinViewController.listOfTags = copyOfListOfTags;
        return;
        
    }
    
    else if([sender isEqualToString:@"viewSelection"]) {
        
        MCDetailViewController *dvc = segue.destinationViewController;
        dvc.listOfPinsToDisplay = (NSArray *)selectedPinsForSegue;
        dvc.listOfTags = (NSArray *)listOfTags;
        dvc.pointerToMainViewController = self;
        return;
        
    } 
    
}

- (IBAction)viewSelectionButtonPressed:(id)sender {
    
    // make list of all selected pins
    [selectedPinsForSegue removeAllObjects];
    
    for(MCLocation *pin in listOfLocationsOnScreen){

            if(pin.displayPin == FALSE){ 
                
                [selectedPinsForSegue addObject:pin]; }
        
    }

    
    // if no selected pins, notify user and exit
    if([selectedPinsForSegue count]==0){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Please make selection." message:@"Before going to the detail page, it is necessary to select which friends you are interested in viewing." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
    }else{
    
        [self performSegueWithIdentifier:@"toDetailViewController" sender:@"viewSelection"];
    }
}

- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue
{
    
}

-(void)addNewPinToListOfLocationsAndSave:(MCLocation *)newPin originalPin:(MCLocation *)oldPin
{
    
    // if editing
    if(oldPin){  

        // if changed photo, need to delete the old
        if(![newPin.imageLocation isEqualToString: oldPin.imageLocation] && ![oldPin.imageLocation isEqualToString:@""]){
        
            NSFileManager *fileManger = [NSFileManager defaultManager];
            NSURL *documentDirectory = [[fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            documentDirectory = [documentDirectory URLByAppendingPathComponent:oldPin.imageLocation];

            [fileManger removeItemAtURL:documentDirectory error:nil];  // Apple recommends not checking for file existence first - in order to predicate behavior, but to deal with errors later
        
        }
        
        // update old pin with new information
        [oldPin editLocationWithTitle:newPin.title coordinate:newPin.coordinate location:newPin.location country:newPin.country notes:newPin.notes imageLocation:newPin.imageLocation tags:newPin.tags];
        oldPin.displayPin = FALSE;
           
    }else{
        
        // add newPin to the array of MCLocations
        newPin.displayPin = FALSE;
        [listOfAllLocations addObject:newPin];
        [self.mapView addAnnotation: newPin];
    }

    [self savePins];  
    [self updateTableWhenMapRegionChanges]; 
    
}

-(void)savePins  // small number of objects, so will just overwrite for simplicity
{
  
    [self sortLocations:listOfAllLocations];
    
    // convert objects to dictionaries and store in array
    NSMutableArray *plist = [NSMutableArray new];
    
    for(MCLocation *z in listOfAllLocations){
        
        // convert objects into dictionaries and add to plist (an array)
        [plist addObject:[z returnDictionaryOfLocationObject]];
        
    }
    
    // save in plist
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSURL *documentDirectory = [[fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    //NSLog(@"%@", documentDirectory);
    
    [plist writeToURL:[documentDirectory URLByAppendingPathComponent:@"csfriends.plist"] atomically:YES];

}

#pragma mark MapViewDelegate

-(MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id<MKAnnotation>)locationToDisplay
{
    
    // if pin unselected return purple pin
    if( [(MCLocation *)locationToDisplay displayPin]){

        MKPinAnnotationView *pin;
        pin = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
       
        if (!pin) {

            pin =[[MKPinAnnotationView alloc]initWithAnnotation:locationToDisplay reuseIdentifier:@"pin"];

        } else {
            
             pin.annotation = locationToDisplay;
        }
        
        pin.pinColor = MKPinAnnotationColorPurple;
        pin.alpha = .6;
        return pin;
    
    }else{
        
        // if pin is selected and default set to show imagePin
        if(showImageNotPin && terminateAutomatedTour == TRUE){
   
            MCAnnotationView *pin2;
            pin2 = (MCAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:@"pinImage"];
            
                                NSLog(@"pin %@", pin2.locationToDisplay.title);   
            
            if (!pin2) {

                pin2 = [[MCAnnotationView alloc]initFromLocationToDisplay:locationToDisplay font:fontNormal scaleFactor:scaleFactorToConvertSizesFromIPhoneToIPad];

            } else {
                
                                NSLog(@"     %@", locationToDisplay.title);       
                
                pin2.annotation = locationToDisplay;
                [pin2 reloadInputViews];
        
                                NSLog(@"            %@", pin2.annotation.title); 
                
                [pin2 setViewComponentsValues];
    
            }
            
            return pin2;
            
        }else{ 
  
            // return red pin to show that it is selected
            MKPinAnnotationView *pin3;
            pin3 = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
          
            if (!pin3) {
                
                pin3 =[[MKPinAnnotationView alloc]initWithAnnotation:locationToDisplay reuseIdentifier:@"pin"];
                
            } else {
                
                pin3.annotation = locationToDisplay;
            }
            
            pin3.pinColor = MKPinAnnotationColorRed;
            pin3.alpha = 1;
            return pin3;         
            
        }
    }

}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{ 
    // pop up button not required
}

-(void)mapView:(MKMapView *)mv regionDidChangeAnimated:(BOOL)animated
{
    
    if(screenAndPositionLayoutCompleted) {
        
        [self updateTableWhenMapRegionChanges];
    }
    
}

-(void)mapView:(MKMapView *)mv didSelectAnnotationView:(MKAnnotationView *)view
{

  // touch events are blocked by mapView
  // when select item, it will call this method, so you can intercept it here
    
  // Apple will deselect all other items
  // to get touches, keep everything deselected
  // then, when something is selected, track it yourself
    
  
  // remember that your Annotation is passed by reference to MCAnnotationViews
  // ie, it is attached to your view: view.annotation
  // so any changes that you make to your MCLocations, will be made to the views 
  // as well and when you call mapView methods, the info will be current
    
    
    // deselect all pins
    for(MCLocation *z in listOfFilteredLocations)  
    {
    	[mapView deselectAnnotation:z animated:NO];
    }  

    // toggle pin and refresh map and table
    [self togglePin:[view annotation]];
    [self refreshMapWithListOfEditedPinsOrNilForAll: nil];
    [self updateTableWhenMapRegionChanges];
}

-(void)refreshMapWithListOfEditedPinsOrNilForAll:(NSMutableArray *)arry
{
    
    if(arry == nil){ arry = listOfAllLocations; }
    
    // update screen 
    // to get mapView to reload, need to remove annotations you are working with and then re-add them all again (or just remove all and re-add all, recommended)
    // regardless, you will get an itermitent flicker
    
    [self.mapView removeAnnotations: arry];
    [self.mapView addAnnotations: listOfFilteredLocations];
    
    [mapView reloadInputViews];
}


#pragma mark Map View Overlay

//  1) create an MKPolygon (or MKPolyline)
//  2) add it to mapView (it is just a chunk of data)
//  3) now, you need to tell your mapView how to display the data
//     it will ask you for additional info in the mapView viewForOverlay delegate
//     (it will give you your MKPolygon data and ask you to wrap it in a view;
//     it is the view which will define things like line width and color)


-(void)makeMapPolygonForTags
{
    
    // for each tag
    for(MCTag *tag in listOfTags){

        // get coordinates for all of tag's location and store in c-array  
        if(tag.selected && tag.displayTripLines){
            
            NSMutableArray *locationsForTag = [self makeListOfFilteredLocationsForTag:tag];
            MCLocation *finalDestination = [self findPointerToFinalDestinationForTrip:tag locationsForTag:locationsForTag];

            int lengthCArray = (int)[locationsForTag count];
            if(finalDestination) { lengthCArray++; }
            CLLocationCoordinate2D cArray[lengthCArray];
            
            int counter = 0;
            
            for(MCLocation *loc in locationsForTag){
                
                cArray[counter] = CLLocationCoordinate2DMake(loc.coordinate.latitude, loc.coordinate.longitude);
                counter++;
            }
             
            if(finalDestination){
            
                cArray[lengthCArray -1] = CLLocationCoordinate2DMake(finalDestination.coordinate.latitude, finalDestination.coordinate.longitude);
                
            }
            
            tag.linesConnectingTripLocations = [MKPolyline polylineWithCoordinates:cArray count:lengthCArray];
            
        }
    }
    
    // add to map
    [self displayTripLinesOverlay];
    
}

-(MCLocation *)findPointerToFinalDestinationForTrip:(MCTag *)tag locationsForTag:(NSMutableArray *)locationsForTag
{

    for(MCLocation *loc in locationsForTag){
    
        if([loc.title isEqualToString: tag.finalDestination]){
            
            return loc;
            
        }
    
    }

    return nil;                
}

-(NSMutableArray *)makeListOfFilteredLocationsForTag:(MCTag *)tag
{
    // filter locations so displays only locations with selected tag 
    // (ie, the tag is in the attached array of tags)
    
    NSMutableArray *listOfFilteredLocationsForTag = [NSMutableArray new];
    
    for(MCLocation *loc in listOfAllLocations){
        
        // does the loc have the desired tag and what is the pointer to the tag?
        MCTag *foundTag = [self searchForTag:tag inLocationObject:loc];

        // notes: tags will be ordered (unless new location added)
        if(foundTag){
            
            loc.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt = foundTag;
            [listOfFilteredLocationsForTag addObject:loc];
            
        }
        
    }
    
    // sort
    [listOfFilteredLocationsForTag sortUsingComparator:^NSComparisonResult(MCLocation *obj1, MCLocation *obj2) {
        
        if(obj1.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt.positionInTripAndArray 
         < obj2.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt.positionInTripAndArray){
            return -1;
        }else{
            return 1;
        }
        
    }];
     
    return listOfFilteredLocationsForTag;
}

-(MCTag *)searchForTag:(MCTag *)searchFor inLocationObject:(MCLocation *)loc
{
    for(MCTag *tag in loc.tags){
        
        if ([tag.tagName isEqualToString: searchFor.tagName]){
            
            return tag; }
        
    }
    
    return nil;
}

-(void)displayTripLinesOverlay
{
    
    // colors will be pulled from this list one by one
    colorsForOverlay = [NSMutableArray arrayWithObjects:[UIColor redColor], [UIColor blueColor], [UIColor brownColor], [UIColor purpleColor], [UIColor orangeColor], [UIColor greenColor], [UIColor yellowColor], [UIColor magentaColor], [UIColor cyanColor], nil];
    
    // remove old overlay, it may have been changed
    for(id x in mapView.overlays){
        
        if([x isKindOfClass:[MKPolyline class]]){
        
            [mapView removeOverlay: x];
        }
    
    }
    
    // for each selected tag set to display trip lines, add overlay
    for(MCTag *tag in listOfTags){
        
        if(tag.selected && tag.displayTripLines){
                
            [mapView addOverlay:tag.linesConnectingTripLocations];
            
        }
        
    }

     [mapView reloadInputViews];
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{

    if ([overlay isKindOfClass:[MKPolyline class]])  {
        
        // get next color
        UIColor *colorOfOverlay;
        
        if([colorsForOverlay count]==0){
            
            colorOfOverlay = [UIColor grayColor];
        
        } else {
            
            colorOfOverlay = colorsForOverlay[0];
            [colorsForOverlay removeObject:colorOfOverlay];
        }
        
        MKPolylineRenderer* polyView = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline*)overlay];
        
        polyView.strokeColor = [colorOfOverlay colorWithAlphaComponent:.5];
        polyView.lineWidth = 5;
        polyView.lineDashPattern =  [NSArray arrayWithObjects:[NSNumber numberWithFloat:12],[NSNumber numberWithFloat:8], nil];
        
        return polyView;
        
    } else {
        
        return nil;
    }
    
    
}


#pragma mark TableView 

-(void)updateTableWhenMapRegionChanges                
{
    [listOfLocationsOnScreen removeAllObjects];
    
    for(MCLocation *z in [mapView annotationsInMapRect: mapView.visibleMapRect]){
        
        [listOfLocationsOnScreen addObject: z];
    }
    
    [self sortLocations:listOfLocationsOnScreen];
    [mapView reloadInputViews];
    [table reloadData];
}

-(void)sortLocations:(NSMutableArray *)arry
{
    // sort by longitude
    
    [arry sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
     
         
         if([(MCLocation *)obj1 coordinate].longitude < [(MCLocation *)obj2 coordinate].longitude){
             
             return -1;
         
         }else{
             
             return 1;
     
         }
         
     }];
     
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"aaa"];
    
    if(!cell){
    
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"aaa"];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = fontBig;
        cell.detailTextLabel.font = fontSmall;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // cell height set in heightForRowAtIndex
    }

    // get MCLocation object
    MCLocation *loc = [listOfLocationsOnScreen objectAtIndex:indexPath.row];
    
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
    
    NSString *str = loc.location;
    if(![loc.notes isEqualToString:@""]) { 
        str = [NSString stringWithFormat:@"%@. (%@)",str, loc.notes];}
    cell.detailTextLabel.text = str;

    // add checkmark
    if(loc.displayPin) {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }else{
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;   
        
    }

    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [self togglePin: [listOfLocationsOnScreen objectAtIndex: indexPath.row]];
    
    [self filterPinsAndDisplay];  
    [table reloadData];        

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [listOfLocationsOnScreen count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 2 * fontBig.lineHeight;
    
}

#pragma mark View Regions

- (IBAction)europeButtonPressed:(id)sender {
    
    // set map region
    CLLocationCoordinate2D centerPointOfMap = CLLocationCoordinate2DMake(52.5, 13.4);
    MKCoordinateSpan sizeOfMapToShow = MKCoordinateSpanMake(30, 30);
    MKCoordinateRegion showMapRegion = MKCoordinateRegionMake(centerPointOfMap, sizeOfMapToShow);
    
    [mapView setRegion:showMapRegion animated:YES];
}

- (IBAction)asiaButtonPressed:(id)sender {
    
    // set map region
    CLLocationCoordinate2D centerPointOfMap = CLLocationCoordinate2DMake(32, 105);
    MKCoordinateSpan sizeOfMapToShow = MKCoordinateSpanMake(65, 65);
    MKCoordinateRegion showMapRegion = MKCoordinateRegionMake(centerPointOfMap, sizeOfMapToShow);
    
    [mapView setRegion:showMapRegion animated:YES];
}

- (IBAction)northAmericaButtonPressed:(id)sender {
    
    // set map region
    CLLocationCoordinate2D centerPointOfMap = CLLocationCoordinate2DMake(39, -95);
    MKCoordinateSpan sizeOfMapToShow = MKCoordinateSpanMake(50, 50);
    MKCoordinateRegion showMapRegion = MKCoordinateRegionMake(centerPointOfMap, sizeOfMapToShow);
    
    [mapView setRegion:showMapRegion animated:YES];
}

- (IBAction)southAmericaButtonPressed:(id)sender {
    
    // set map region
    CLLocationCoordinate2D centerPointOfMap = CLLocationCoordinate2DMake(-15, -56);
    MKCoordinateSpan sizeOfMapToShow = MKCoordinateSpanMake(60, 60);
    MKCoordinateRegion showMapRegion = MKCoordinateRegionMake(centerPointOfMap, sizeOfMapToShow);
    
    [mapView setRegion:showMapRegion animated:YES];
}

- (IBAction)africaButtonPressed:(id)sender {
    
    // set map region
    CLLocationCoordinate2D centerPointOfMap = CLLocationCoordinate2DMake(2, 21);
    MKCoordinateSpan sizeOfMapToShow = MKCoordinateSpanMake(75, 75);
    MKCoordinateRegion showMapRegion = MKCoordinateRegionMake(centerPointOfMap, sizeOfMapToShow);
    
    [mapView setRegion:showMapRegion animated:YES];
}


#pragma mark Tour Region

- (IBAction)tourRegion:(id)sender {
    
    // create action sheet so you can choose your tour
    actionSheetTour = [[UIActionSheet alloc]initWithTitle:@"Choose Your Tour" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    // add buttons (can't pass an array into an action sheet, so need to add manually)

    [actionSheetTour addButtonWithTitle:[NSString stringWithFormat:@"Tour Region"]];
    [actionSheetTour addButtonWithTitle:[NSString stringWithFormat:@"Tour World"]];
     
    // one button for each selected tag
    for(MCTag *trip in listOfTags){
    
        if(trip.selected && trip.displayTripLines){
        
            [actionSheetTour addButtonWithTitle:[NSString stringWithFormat:@"%@ Trip", [trip.tagName substringWithRange:NSMakeRange(1, [trip.tagName length]-2 )]]];
        }
        
    }
    
    [actionSheetTour addButtonWithTitle:[NSString stringWithFormat:@"Cancel"]];
          
    [actionSheetTour showInView:self.view];

    
}

-(void)tourRegionSetup
{
    
    // if there are no locations, run world tour instead
    if([listOfLocationsOnScreen count] == 0) {

        [self tourWorldSetup];
        return;
        
    }
    
    // make copy of list of locations to work with, we will view each item in the list
    NSMutableArray *arry = [NSMutableArray arrayWithArray:listOfLocationsOnScreen];
    
    // already sorted   
    
    // start tour
    [self tourSetup2:arry];
 
}

-(void)tourWorldSetup
{
    
    // if there are no locations, run introTourInstead
    if([listOfFilteredLocations count] == 0) {
        
        [self intro_delay:0];
        return;
        
    }
    
    
    // create copy of list of all locations to work with
    NSMutableArray *arry = [NSMutableArray arrayWithArray: listOfFilteredLocations ];

    [self sortLocations:arry];
        
    // move to correct region (or get incorrect zooming behavior)
    MKCoordinateRegion showMapRegion = MKCoordinateRegionMake([(MCLocation *)[listOfFilteredLocations objectAtIndex: [listOfFilteredLocations count] - 1] coordinate] , mapView.region.span);
    [mapView setRegion:showMapRegion animated:YES];
    
    [self performSelector:@selector(tourSetup2:) withObject:arry afterDelay:1];        

}

-(void)tourTripSetup:(MCTag *)trip
{
    
    // for all locations, check to see if it has the desired tag and store in arry
    // (similar to code in overlay section, but with a couple differences)
    
    NSMutableArray *locationsForTrip = [NSMutableArray new];

    for(MCLocation *checkThisLoc in listOfAllLocations){
        
        // if find tag, save pointer to it (just makes it a little easier to work with)
        checkThisLoc.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt = [self checkToSeeIfPinMeetsFilterCriteria:checkThisLoc listOfSelectedTags:[NSMutableArray arrayWithObject:trip]];
        
        // if find tag, add location to list of places will tour
        if(checkThisLoc.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt){
            
            [locationsForTrip addObject:checkThisLoc];
            
        }
        
    }
    
    // sort
    [self sortByPositionInTrip:locationsForTrip];
    
    
    // add final destination to our list
    for(MCLocation *loc in locationsForTrip){
        
        if([loc.title isEqualToString: trip.finalDestination]){
            
            [locationsForTrip insertObject:loc atIndex:0];
            break;
        }
        
    }
    
    //debug
    //for(MCLocation *loc in locationsForTrip){NSLog(@"%i %@", loc.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt.positionInTripAndArray, loc.title);}  // note: the position number is used to sort, then the final position is added to the stack, but it is just a pointer to the its first occurence
    
    // start tour
    [self tourSetup2: locationsForTrip];
    
}

-(void)sortByPositionInTrip:(NSMutableArray *)locationsForTrip
{

    // sort by position
    [locationsForTrip sortUsingComparator:^NSComparisonResult(MCLocation *obj1, MCLocation *obj2) {
        
        int a = obj1.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt.positionInTripAndArray;
        int b = obj2.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt.positionInTripAndArray;
        
        if(a <= b){
            
            return 1;
            
        }else{
            
            return -1;
            
        }
        
    }];
}

- (void)tourSetup2:(NSMutableArray *)arry
{

    // block user input
    fullScreenViewToBlockInputs.hidden = FALSE;
    terminateAutomatedTour = FALSE;
    [self fadeMenus];
    [self playMusic];
    
    // hide table
    table.hidden = TRUE;
    
    // change all pins to pin view (may scroll to show pins not on current screen, so changes all pins)
    for(MCLocation *z in listOfFilteredLocations){
        
        if(z.displayPin == FALSE) {
            
            [self togglePin: z]; }
    }

    [self refreshMapWithListOfEditedPinsOrNilForAll: nil];

    // start tour
    [self nextStepOnMapWithArray:arry];

}

-(void)nextStepOnMapWithArray:(NSMutableArray *)arry
{

    if(terminateAutomatedTour || [arry count] == 0 ){
        
        [self terminateAutomatedProcess];
        return;
    }
    
    // zoom out if zoomed in too far (only relivant after first pass)
    
    [self zoomOutFromLocation: arry];  // this method will call nextStepOnMapWithArrayB when completed, after appropriate delay
}

-(void)nextStepOnMapWithArrayB:(NSMutableArray *)arry
{
    // zoom in on location and toggle pin
    MCLocation *loc = [arry objectAtIndex:[arry count]-1];
    [self togglePin:loc];
    [self displayTourHeaderInfo:loc];
    [self refreshMapWithListOfEditedPinsOrNilForAll: nil];
    [self zoomInOnLocation:loc];
    tour_NameAndImage.hidden = FALSE;
    tour_LocationLabel.hidden = FALSE;
    
    // recursion
    [arry removeObjectAtIndex:[arry count]-1];

    if([arry count]!=0){
        [self performSelector:@selector(nextStepOnMapWithArray:) withObject:arry afterDelay:3]; 
        [self performSelector:@selector(togglePin:) withObject:loc afterDelay:3];} 
}

-(void)zoomOutFromLocation:(NSMutableArray *)arry
{
    
    MCLocation *nextPin = [arry objectAtIndex:[arry count]-1];
    BOOL shouldZoomOut = TRUE;
    
    // check to see if next pin is on the screen
    for(MCLocation *loc in listOfLocationsOnScreen){
        
        if(loc == nextPin){ shouldZoomOut = FALSE;}
    }
    
    if(shouldZoomOut){
        
        // set map region
        MKCoordinateSpan sizeOfMapToShow = MKCoordinateSpanMake(25,25);
        MKCoordinateRegion showMapRegion = MKCoordinateRegionMake(mapView.region.center, sizeOfMapToShow);
        [mapView setRegion:showMapRegion animated:YES];
        
        // run nextStep
        [self performSelector:@selector(nextStepOnMapWithArrayB:) withObject:arry afterDelay:1.3];
    
    }else{
        
        [self nextStepOnMapWithArrayB:arry];
        
    }
    
}

-(void)zoomInOnLocation:(MCLocation *)centerPin
{
    
    // look at other pins, if too close, zoom in more
    
    float minDistanceBetweenPins = 20;

    
    // first, will need to convert center pin location from lat/long to CGPoint (location in view)
    
        // REMEMBER:
        // map coordinate = latitude/longitude 
        // map point = x,y on flattened map (use MKMapSize and MKMapRect structures)
        // point = x,y in view
        // (see guide for conversion from one to another, or google mk framework)
    
    CGPoint centerPoint = [mapView convertCoordinate:centerPin.coordinate toPointToView:mapView];
                
    // go thru each pin to find out how far it is from the center
    
    float distance;
    float smallestDistance = 100000;  // just big number (sloppy, but simplifies code)
    // CGPoint nearestPoint;
    
    for(MCLocation *pin in listOfLocationsOnScreen){ 
        
        CGPoint otherPoint = [mapView convertCoordinate:pin.coordinate toPointToView:mapView];
        
        // find distance using distance formula
        distance = sqrtf(pow(centerPoint.x - otherPoint.x, 2) + pow(centerPoint.y - otherPoint.y, 2));
        
        
        // keep track of smallest  (if checking self or pin sharing same loc, skip)
        if(distance > 0.00001 && distance < smallestDistance) {
            
            smallestDistance = distance;    // nearestPoint = otherPoint;
        }

    }        
    
    // if nearby pin too close, calculate how far need to move it away and do so
    if(smallestDistance < minDistanceBetweenPins){  

        // to simplify the process, we will pretend that the distance is an x component
        //  which will give us a suitable scale factor
        
        // smallestDistance * scaleFactor = minDistanceBetweenPins
        float scaleFactor = minDistanceBetweenPins/smallestDistance;

        // switch back into coord (more convenient, giving it a center point)
        //  scaleFactor will also work on span (want smaller number so divide)
        CLLocationCoordinate2D centerPointOfMap = centerPin.coordinate;
        MKCoordinateSpan sizeOfMapToShow = MKCoordinateSpanMake(mapView.region.span.latitudeDelta/scaleFactor, mapView.region.span.longitudeDelta/scaleFactor);
        MKCoordinateRegion showMapRegion = MKCoordinateRegionMake(centerPointOfMap, sizeOfMapToShow);
        
        [mapView setRegion:showMapRegion animated:YES];
             
    }else{
        
        CLLocationCoordinate2D centerPointOfMap = centerPin.coordinate;        
        MKCoordinateRegion showMapRegion = MKCoordinateRegionMake(centerPointOfMap, mapView.region.span);
        [mapView setRegion:showMapRegion animated:YES];
        
    }
    
}

-(void)displayTourHeaderInfo:(MCLocation *)loc
{
    
    // update display/annotation field and display
    tour_NameAndImage.locationToDisplay = loc;
    [tour_NameAndImage setViewComponentsValues];

    tour_NameAndImage.frame = CGRectMake(
        self.view.frame.size.width/2 - tour_NameAndImage.frame.size.width/2, 
        menu_moveToRegion.frame.size.height + mapView.frame.size.height + menu_mainMenu.frame.size.height + self.view.frame.size.height * .045, 
        (self.view.frame.size.width - 20) * scaleFactorToConvertSizesFromIPhoneToIPad, 
        tour_NameAndImage.frame.size.height * scaleFactorToConvertSizesFromIPhoneToIPad   );

    // update text field 
    tour_LocationLabel.text = loc.location;
    tour_LocationLabel.frame = CGRectMake(0, 
        tour_NameAndImage.frame.origin.y + self.view.frame.size.height * .08, 
        self.view.frame.size.width, 
        30);

}

- (IBAction)fullScreenToBlockInputsRecievesInput:(id)sender {
}

-(void)terminateAutomatedProcess
{
    
    terminateAutomatedTour = TRUE;
    fullScreenViewToBlockInputs.hidden = TRUE;
    
    tour_NameAndImage.hidden = TRUE;
    tour_LocationLabel.hidden = TRUE;
    table.hidden = FALSE;
    
    [self performSelector:@selector(unfadeMenus) withObject:nil afterDelay:.6]; 
    [self performSelector:@selector(fadeMusic) withObject:nil afterDelay:1];

}

-(void)playMusic
{
    
    // get file from the app bundle (it is not in the documents folder)
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/music.m4a", [[NSBundle mainBundle] resourcePath]]];       
	NSError *error;
	musicAndPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	musicAndPlayer.numberOfLoops = -1;  // -1 means will loop
	
	if (musicAndPlayer == nil) {
		NSLog(@"%@",[error description]);
    }
	else {
        [musicAndPlayer setVolume: .6];
        musicAndPlayer.currentTime = 0;   // restart from begining
		[musicAndPlayer play];         // will be paused in terminatedAutomatedProc
    }
    
} 

-(void)fadeMusic
{
      
    musicAndPlayer.volume -= .1;
    
    if (musicAndPlayer.volume <= 0) {
        
        [musicAndPlayer pause]; 
    
    }else{
    
        [self performSelector:@selector(fadeMusic) withObject:nil afterDelay:.3];
    }
   

}

-(void)fadeMenus
{

    menu_mainMenu.alpha = .5;
    menu_moveToRegion.alpha = .5;
}

-(void)unfadeMenus
{

    menu_mainMenu.alpha = 1;
    menu_moveToRegion.alpha = 1;

}

#pragma mark Global Access

-(UIFont *)returnFontSmall { return fontSmall; }
-(UIFont *)returnFontBig { return fontBig; }
-(UIFont *)returnFontNormal { return fontNormal; }
-(float)returnScaleFactor { return scaleFactorToConvertSizesFromIPhoneToIPad; }
-(NSMutableArray *)returnListOfAllLocations {return listOfAllLocations;}
-(NSMutableArray *)returnListOfFilteredLocations {return listOfFilteredLocations;}
-(NSMutableArray *)returnListOfTags {return listOfTags;}

@end



