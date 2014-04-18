//
//  MCSelectTagViewController.m
//  CSFriends
//
//  Created by xcode on 12/6/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import "MCSelectTagViewController.h"
#import "MCViewController.h"
#import "MCOrderTripViewController.h"
#import "UIViewController+ResizingForDifferentDevices.h"
#import "MCAppDelegate.h"

@interface MCSelectTagViewController ()

  @property (strong, nonatomic) IBOutlet UITextField *textFieldForEnteringNewTags;
  @property (strong, nonatomic) IBOutlet UITableView *tableOfTags;
  @property (strong, nonatomic) IBOutlet UIView *createTagOverlayView;
  @property (strong, nonatomic) IBOutlet UIView *createTagSubview;

  @property MCTag *tagBeingEdited;

  // screen items
  @property (strong, nonatomic) IBOutlet UILabel  *titleLabel;
  @property (strong, nonatomic) IBOutlet UIButton *backButton;

  @property (strong, nonatomic) IBOutlet UIButton *selectAllButton;
  @property (strong, nonatomic) IBOutlet UIButton *deselectAllButton;
  @property (strong, nonatomic) IBOutlet UIButton *nwButton;
  @property (strong, nonatomic) IBOutlet UIButton *editTagButton;
  @property (strong, nonatomic) IBOutlet UIButton *deleteSelectedButton;

  // subview buttons
  @property (strong, nonatomic) IBOutlet UIButton *cancelButton;
  @property (strong, nonatomic) IBOutlet UIButton *createNewTagButton;
  @property (strong, nonatomic) IBOutlet UIButton *saveButton;
  @property (strong, nonatomic) IBOutlet UIButton *convertToTrip;

  // main view
  - (IBAction)backButtonPressed:(id)sender;
  - (IBAction)swipeRight:(id)sender;

  - (IBAction)selectAllButtonPressed:(id)sender;
  - (IBAction)deselectAllButtonPressed:(id)sender;
  - (IBAction)nwButtonPressed:(id)sender;
  - (IBAction)editButtonPressed:(id)sender;
  - (IBAction)deleteSelectedTags:(id)sender;

  // subview
  - (IBAction)createNewTagButtonPressed:(id)sender;
  - (IBAction)saveButtonPressed:(id)sender;
  - (IBAction)exitSubviewButtonPressed:(id)sender;

  // methods
  -(void)deleteSelectedTagsFromMasterListAndMCLocations;
//-(void)saveListOfTags;  in .h file

@end

@implementation MCSelectTagViewController
  @synthesize listOfTags, tableOfTags, textFieldForEnteringNewTags, createTagOverlayView, delegate, backButton, cancelButton, titleLabel, selectAllButton, deselectAllButton, editTagButton, deleteSelectedButton, createNewTagButton, createTagSubview, saveButton, convertToTrip, tagBeingEdited, nwButton;


// delete selected tags, not working ??? (is it because saved sooner, or because never worked?

#pragma mark Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tableOfTags.delegate = self;
    tableOfTags.dataSource = self;
    textFieldForEnteringNewTags.delegate = self;
    
    createTagOverlayView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    createTagSubview.frame = CGRectMake(0, 0, self.view.frame.size.width, createTagSubview.frame.size.height * [delegate returnScaleFactor]);
    
    createTagOverlayView.hidden = TRUE;
    createTagSubview.hidden = TRUE;
    
    [self resizeFontAndSpace];

}

-(void)resizeFontAndSpace
{
    
    [self changeFontSizeForButtonsAndLabels:
        [[NSMutableArray alloc] initWithObjects:backButton, 
                                                cancelButton, 
                                                convertToTrip,
                                                editTagButton, 
                                                titleLabel, nil] 
        fontSize:[delegate returnFontBig] 
        scaleFactorToConvertSizesFromIPhoneToIPad:[delegate returnScaleFactor]];

    [self changeFontSizeForButtonsAndLabels:
        [[NSMutableArray alloc] initWithObjects:deselectAllButton, 
                                                deleteSelectedButton, 
                                                selectAllButton, 
                                                textFieldForEnteringNewTags, 
                                                createNewTagButton, 
                                                saveButton, 
                                                nwButton,
                                                nil] 
        fontSize:[delegate returnFontNormal]
        scaleFactorToConvertSizesFromIPhoneToIPad:[delegate returnScaleFactor]];
    
    
    [self spaceObjectsEvenlyAlongXAxis:[NSMutableArray arrayWithObjects:selectAllButton, deleteSelectedButton, nwButton, deselectAllButton, nil]];
    [self spaceObjectsEvenlyAlongXAxis: [NSMutableArray arrayWithObject: titleLabel]];
    [self spaceObjectsEvenlyAlongXAxis: [NSMutableArray arrayWithObjects: createNewTagButton, nil]];
    [self spaceObjectsEvenlyAlongXAxis: [NSMutableArray arrayWithObjects: saveButton, nil]];
    [self spaceObjectsEvenlyAlongXAxis: [NSMutableArray arrayWithObject: textFieldForEnteringNewTags]];
    
    saveButton.hidden = TRUE;
    createNewTagButton.hidden = TRUE;
    convertToTrip.hidden = TRUE;
    
    tableOfTags.frame = CGRectMake(tableOfTags.frame.origin.x, tableOfTags.frame.origin.y * [delegate returnScaleFactor], tableOfTags.frame.size.width, tableOfTags.frame.size.height);  // since already resized subviews manually, must turn off autoresize in storyboard which doesn't take care of things like fonts and lineHeight
    
    editTagButton.frame = CGRectMake(self.view.frame.size.width - editTagButton.frame.size.width - 15, editTagButton.frame.origin.y, editTagButton.frame.size.width, editTagButton.frame.size.width);

    convertToTrip.frame = CGRectMake(self.view.frame.size.width - convertToTrip.frame.size.width - 15, convertToTrip.frame.origin.y, convertToTrip.frame.size.width, convertToTrip.frame.size.height);
}


#pragma mark Buttons

- (IBAction)selectAllButtonPressed:(id)sender 
{
    
    for(MCTag *z in listOfTags){
        
        z.selected = TRUE;
        
    }
    
    [tableOfTags reloadData];
    
}

- (IBAction)deselectAllButtonPressed:(id)sender {
    
    for(MCTag *z in listOfTags){
        
        z.selected = FALSE;
        
    }
    
    [tableOfTags reloadData];
}


- (IBAction)backButtonPressed:(id)sender {
    
    [self saveListOfTags];
    // unwind to main view controller (in storyboard)
}


- (IBAction)nwButtonPressed:(id)sender {

    textFieldForEnteringNewTags.text = @"";
    
    createTagOverlayView.hidden = FALSE;
    createTagSubview.hidden = FALSE;

    createNewTagButton.hidden = FALSE;

}

- (IBAction)editButtonPressed:(id)sender {
    
    // get first selected tag to edit
    
    tagBeingEdited = nil;
    
    for(MCTag *tag in listOfTags){
        
        if(tag.selected){
            
            tagBeingEdited = tag;
            textFieldForEnteringNewTags.text = [tagBeingEdited.tagName substringWithRange:NSMakeRange(1, [tagBeingEdited.tagName length] - 2)]; 
            break;
            
        }
    }

    // deselect all tags
    
    for(MCTag *tag in listOfTags){
        
        if(tag != tagBeingEdited){

            [tag setSelected:NO];
        
        }
        
    }     
    
    [tableOfTags reloadData];
    createTagSubview.hidden = FALSE;
    saveButton.hidden = FALSE;    
    convertToTrip.hidden = FALSE;
}



- (IBAction)deleteSelectedTags:(id)sender {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Tags" message:@"Deleting tags will remove tags both from this list and from individual entries." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            [self deleteSelectedTagsFromMasterListAndMCLocations];
            break;

            
    }
}


#pragma mark TableView

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"zzz"];
    
    if(!cell){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
        cell.textLabel.font = [delegate returnFontBig];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    // look up to see if need to add checkmark
    // (note: setting UITableViewCellAccessoryCheckmark has no behavior, just image)
    
    if([listOfTags[indexPath.row] selected] == YES) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;    
        
    }else{
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // set title
    cell.textLabel.text = [listOfTags[indexPath.row] tagName];
    
    return cell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [listOfTags count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // toggle whether or not tag is marked as selected
    
    if( [listOfTags[indexPath.row] selected] == YES ){
        
        // deselect tag
        [listOfTags[indexPath.row] setSelected:NO];
        textFieldForEnteringNewTags.text = @"";
        
    }else{
        
        // if editing tags
        if(saveButton.hidden == FALSE){
            
            //before selecting tag, deselect all
            for(MCTag *tag in listOfTags){
                
                [tag setSelected:NO];
                
            }        
            
            //display tagName
            tagBeingEdited = listOfTags[indexPath.row];
            textFieldForEnteringNewTags.text = [tagBeingEdited.tagName substringWithRange:NSMakeRange(1, [tagBeingEdited.tagName length] - 2) ];         
        }
        
        // select tag
        [listOfTags[indexPath.row] setSelected:YES];
    }
    
    [tableOfTags reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 1.7 * [[delegate returnFontBig] lineHeight];
    
}



#pragma mark Edit/Create Tags (in Subview)

// - convertToTrip/editTrip Button segues directly to OrderTripVC (see storyboard)

- (IBAction)createNewTagButtonPressed:(id)sender {
    
    // make sure text field isn't blank
    
    if([textFieldForEnteringNewTags.text isEqualToString:@""]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Try Again" message:@"Please enter tag name before saving" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
        
    }
    
    // check to see if the tag already exists, don't want duplicates
    
    for(MCTag *tag in listOfTags){
        
        if([tag.tagName isEqualToString:[NSString stringWithFormat:@"<%@>", textFieldForEnteringNewTags.text]]){
            
            UIAlertView *alert2 = [[UIAlertView alloc]initWithTitle:@"Tag Already Exists" message:@"Please create a unique tag name." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert2 show];
            return;
        }
        
    }
    
    NSString *tag = [NSString stringWithFormat:@"<%@>",textFieldForEnteringNewTags.text];
    [listOfTags addObject: [[MCTag alloc]initWithTitle:tag isSelected:NO]];
    textFieldForEnteringNewTags.text = @"";
    [textFieldForEnteringNewTags resignFirstResponder];
    [self saveListOfTags];
    [tableOfTags reloadData];
    
}


- (IBAction)saveButtonPressed:(id)sender {
    
    if(![textFieldForEnteringNewTags.text isEqualToString:tagBeingEdited.tagName]){
        
        // go thru listOfAllLocations and replace old name with new name
        
        for(MCLocation *loc in [delegate returnListOfAllLocations]){
        
            [loc editTagsAttachedToMCLocationObject_OldTagName:tagBeingEdited.tagName newTagName_orEmptyStringToDelete:[NSString stringWithFormat:@"<%@>", textFieldForEnteringNewTags.text]];
        
        }
        
        // update tag being edited
        tagBeingEdited.tagName = [NSString stringWithFormat:@"<%@>", textFieldForEnteringNewTags.text];
        
        // save tags and locations
        [self saveListOfTags];
        [delegate savePins];
        
        // refresh
        [tableOfTags reloadData];
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField  // ie, text field should x, on return
{
    //  [self createNewTagButtonPressed:nil];
    return YES;
}

- (IBAction)exitSubviewButtonPressed:(id)sender {
    
    createTagSubview.hidden = TRUE;
    createTagOverlayView.hidden = TRUE;
    
    saveButton.hidden = TRUE;
    createNewTagButton.hidden = TRUE;
    convertToTrip.hidden = TRUE;

    [textFieldForEnteringNewTags resignFirstResponder];
    
}

- (IBAction)swipeRight:(id)sender {
    
    if(createTagOverlayView.hidden == FALSE){
        
        [self exitSubviewButtonPressed:nil];
        
    }else{
        
        [self backButtonPressed:nil];
        [self performSegueWithIdentifier:@"unwindFromTagToMain" sender:nil];
    }
}


#pragma mark Save & Segue

-(void)saveListOfTags
{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSURL *documentDirectory = [[fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

    NSMutableArray *arry = [NSMutableArray new];
    
    for(MCTag *z in listOfTags) {
        
        // convert to dictionary
        [arry addObject: [z convertToDictionary]];
        
    }
    
    [arry writeToURL:[documentDirectory URLByAppendingPathComponent:@"listOfTags.plist"] atomically:NO];
}


-(void)deleteSelectedTagsFromMasterListAndMCLocations
{
    
    // get all selected items
    
    NSMutableArray *copyOfListOfTagsToIterateThru = [NSMutableArray arrayWithArray:listOfTags];
    
    for (MCTag *tag in copyOfListOfTagsToIterateThru)
    {
        if(tag.selected){
            
            // remove from master list
            [listOfTags removeObject:tag];
            
            // remove from all MCLocationObjects
            for(MCLocation *loc in [delegate returnListOfAllLocations]){
                
                [loc editTagsAttachedToMCLocationObject_OldTagName:tag.tagName newTagName_orEmptyStringToDelete:@""];
                
            }
        }
        
    }
    
    [self saveListOfTags];
    [tableOfTags reloadData];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if(sender == convertToTrip){
        
        MCOrderTripViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.pointerToMainViewController = delegate;
        vc.tagSelected = tagBeingEdited;
    }



}
- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue
{
    
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
