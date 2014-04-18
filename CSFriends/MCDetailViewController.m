//
//  MCDetailViewController.m
//  CSFriends
//
//  Created by xcode on 12/9/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import "MCDetailViewController.h"
#import "MCAppDelegate.h"
#import "MCTag.h"
#import "UIViewController+ResizingForDifferentDevices.h"

@interface MCDetailViewController ()

  //@property NSMutableArray *listOfPinsToDisplay;      // declared in .h
  @property int recordIndex;

  @property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
  @property (strong, nonatomic) IBOutlet UIView *canvasForScrollView;

  @property (strong, nonatomic) IBOutlet UIImageView *photo;
  @property (strong, nonatomic) IBOutlet UILabel *nameField;
  @property (strong, nonatomic) IBOutlet UILabel *countryField;
  @property (strong, nonatomic) IBOutlet UILabel *locationField;
  @property (strong, nonatomic) IBOutlet UITextView *notesTextView;

  @property (strong, nonatomic) IBOutlet UIButton *previousButton;
  @property (strong, nonatomic) IBOutlet UIButton *nextButton;
  @property (strong, nonatomic) IBOutlet UIButton *editButton;

  - (void)displayDetailInfo;

  - (IBAction)nextButtonPressed:(id)sender;
  - (IBAction)previousButtonPressed:(id)sender;
  - (IBAction)swipedRight:(id)sender;
  - (IBAction)swipedLeft:(id)sender;

@end

@implementation MCDetailViewController
  @synthesize listOfPinsToDisplay, photo, nameField, countryField, locationField, notesTextView, recordIndex, listOfTags, pointerToMainViewController, editButton, previousButton, nextButton, scrollView, canvasForScrollView;


-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return canvasForScrollView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    scrollView.frame = self.view.frame;
    scrollView.contentSize = canvasForScrollView.frame.size;
    
    // resize for device (height * scale factor)
    // (implements viewForZoomInScrollView protocol)
    scrollView.delegate = self;
    [scrollView setZoomScale: self.view.frame.size.width/canvasForScrollView.frame.size.width animated:YES];  
    scrollView.minimumZoomScale = scrollView.zoomScale;
    [scrollView setContentOffset:CGPointMake(0, 0)];   
    recordIndex = 0;
    [self displayDetailInfo];
}

-(void)viewDidAppear:(BOOL)animated
{
   // rather than changing fonts, used scroll view's zoom feature for to allow zoom
    
    [self updateButtonColors];
    scrollView.hidden = FALSE;
}

-(void)refreshScreen
{
    // can't update screen in view did appear when returning from AddPinViewController because save function is in a completion block, so do it here
    
    [self displayDetailInfo];
}

-(void)displayDetailInfo
{

    MCLocation *detailPin = listOfPinsToDisplay[recordIndex];
    
    nameField.text = detailPin.title;
    countryField.text = [NSString stringWithFormat:@"%@", detailPin.country];
    locationField.text = [NSString stringWithFormat:@"%@", detailPin.location];

    
    // add tags to notesTextField

    
    if([detailPin.tags count]>0){
        
        NSString *str;
        str = @"\n\n  Tags:";
        
        for(MCTag *tag in detailPin.tags){
            str = [NSString stringWithFormat:@"%@ %@", str, tag.tagName];
            
        }
        
        notesTextView.text = [NSString stringWithFormat:@"%@  %@", detailPin.notes, str];
        
    }else{
        
        notesTextView.text = detailPin.notes;
    }
    

    
    // load image
    if(detailPin.location){
        NSFileManager *fileManger = [NSFileManager defaultManager];
        NSURL *documentDirectory = [[fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        NSData *imageData = [NSData dataWithContentsOfURL:[documentDirectory URLByAppendingPathComponent:[detailPin imageLocation] ]];
        photo.image = [UIImage imageWithData:imageData];
        
        if(!photo.image){
            photo.image = [UIImage imageNamed:@"person"];}
        
    } else {        
        
        photo.image = [UIImage imageNamed:@"person"];}


}


-(void)updateButtonColors
{
    
    // set button text colors (to show if there is a next or not)  
    
    // working with button colors can be a little tricky because apple
    // is resetting the colors when you click on a button
    // giving you that nice color change when click on it
    
    // use: setTitleColor:forState: UIControlState...      
        
    // enum { UIControlStateNormal,    
    //        UIControlStateHighlighted,
    //        UIControlStateDisabled, 
    //        UIControlStateSelected }      // can have more than 1
    
    // also may use
    //
    //      button.enabled = TRUE/FALSE;  (so it won't get reset)
    //      adjustsImageWhenHighlighted   (not used here)

    
    // set default colors
    UIColor *colorDefault = [UIColor colorWithRed:0.0 green:122.0/255 blue:255.0/255 alpha:1];
    
    [previousButton setTitleColor:colorDefault forState:UIControlStateNormal];
    [nextButton     setTitleColor:colorDefault forState:UIControlStateNormal];
    
    [previousButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [nextButton     setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];

    [nextButton     setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];

    // when looking at first item (index == 0), display back button, else last
    
    if (recordIndex==0){
        
        [previousButton setTitle:@"Back" forState:UIControlStateNormal];
        [previousButton setTitle:@"Back" forState:UIControlStateSelected];
        
    }else{
        
        [previousButton setTitle:@"Previous" forState:UIControlStateNormal];
        [previousButton setTitle:@"Previous" forState:UIControlStateSelected];
        
    }
    
    // when looking at last item, disable button
    if(recordIndex == [listOfPinsToDisplay count] - 1){
        
        nextButton.enabled = FALSE;
        
    }else{
        
        nextButton.enabled = TRUE;

    }
    
}

- (IBAction)nextButtonPressed:(id)sender {
    
    recordIndex += 1;
    
    [self displayDetailInfo];
    [self updateButtonColors];
    
}

- (IBAction)previousButtonPressed:(id)sender {
    
    recordIndex += -1;
    
    if(recordIndex < 0){
        
        // unwind (to create a unwind segue, draw view controller in left storyboard pane to exit, give unique id, call performSeg on it)
        [self performSegueWithIdentifier:@"unwindToMain" sender:previousButton];
        
         
    }else{
    
        [self displayDetailInfo];
        [self updateButtonColors];
   
    }

}

- (IBAction)swipedRight:(id)sender {
    
    
    [self previousButtonPressed:nil];
    
}

- (IBAction)swipedLeft:(id)sender {
    
    // if not on last item, go to next entry
    if(recordIndex < [listOfPinsToDisplay count] - 1){
        
        [self nextButtonPressed:nil];
        
    }
        
}

#pragma mark Segue 

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if(sender == previousButton){
    
        return;
    }
       
    if(sender == editButton){
        
        // create copy of listOfTags to work with 
        NSMutableArray *copyOfListOfTags = [NSMutableArray new];
        for(MCTag *z in listOfTags){
            [copyOfListOfTags addObject:[[MCTag alloc]initWithTitle:z.tagName isSelected:FALSE]];}
        
        // set delegate, etc.
        MCAddPinViewController *addPinViewController = segue.destinationViewController;
        addPinViewController.delegate = self;
        addPinViewController.pointerToMainViewController = pointerToMainViewController;
        addPinViewController.listOfTags = copyOfListOfTags;
        
        addPinViewController.originalPin = listOfPinsToDisplay[recordIndex]; 
        
        // don't want to work with original, so create a second copy 
        addPinViewController.temporaryPinForEditing = [listOfPinsToDisplay[recordIndex] createCopy];

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
