//
//  MCAddPinViewController.m
//  CSFriends
//
//  Created by xcode on 11/27/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import "MCAddPinViewController.h"
#import "MCLocation.h"
#import "MCTag.h"
#import "MCCheckMapViewController.h"
#import "MCViewController.h"
#import "MCAppDelegate.h"
#import "UIViewController+ResizingForDifferentDevices.h"
#import <MapKit/MapKit.h>

@interface MCAddPinViewController ()

  // in .h file
  // @property id<MCAddPinViewProtocol>delegate;
  // @property MCLocation *currentPin;
  // @property MCLocation *originalPin;  

  @property (strong, nonatomic) IBOutlet UITextField *textField_Location;
  @property (strong, nonatomic) IBOutlet UITextField *textField_Country;
  @property (strong, nonatomic) IBOutlet UITextField *textField_Name;
  @property (strong, nonatomic) IBOutlet UIImageView *photoImage;
  @property (strong, nonatomic) IBOutlet UITextView *textView_notes;
  @property (strong, nonatomic) IBOutlet UITableView *tableOfTags;

  @property (strong, nonatomic) IBOutlet UIScrollView *theScrollView;
  @property (strong, nonatomic) IBOutlet UIView *canvas;
  @property UIImagePickerController *picker;
  @property UIImage *rawImageFromPicker;


  @property NSDictionary *dictionaryOfWebData;
  @property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
  @property (strong, nonatomic) IBOutlet UIButton *checkLocationButton;

  - (void)setup;

  - (IBAction)saveButtonPressed:(id)sender;
  - (IBAction)cancelButtonPressed:(id)sender;
  - (IBAction)editImageButtonPressed:(id)sender;
  - (IBAction)checkLocationButtonPressed:(id)sender; 
  
  - (void)getDataFromWeb;
  - (void)parseDictionaryAndSegue;
  - (void)storeScreenData:(CLLocationCoordinate2D)coord;
  - (void)savePhotoAndStoreFileName;

  - (void)dismissKeyboard;

@end

@implementation MCAddPinViewController
  @synthesize textField_Location, textField_Country, textField_Name, photoImage, textView_notes, delegate, theScrollView, canvas, temporaryPinForEditing,  dictionaryOfWebData, spinner, picker, originalPin, tableOfTags, listOfTags, checkLocationButton, pointerToMainViewController, rawImageFromPicker;


-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return canvas;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    
    // resize for device (height * scale factor)
    // must implement viewForZoomInScrollView protocol
    theScrollView.delegate = self;
    [theScrollView setZoomScale: self.view.frame.size.width/canvas.frame.size.width animated:YES];  
    [theScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    theScrollView.hidden = FALSE;
}

-(void)setup
{
    // setup scroll view and spinner
    theScrollView.frame = self.view.frame;
    theScrollView.contentSize = CGSizeMake(self.view.frame.size.width, canvas.frame.size.height);
    
    spinner.hidden = YES;
    spinner.hidesWhenStopped = YES;
    spinner.color = [UIColor redColor];
  
    // set delegates
    textField_Name.delegate = self;
    textField_Country.delegate = self;
    textField_Location.delegate = self;
    textView_notes.delegate = self;
    tableOfTags.delegate = self;
    tableOfTags.dataSource = self;
    
    if(!temporaryPinForEditing){
        temporaryPinForEditing = [MCLocation new];
        return;
    }
    
    // load data   
    textField_Name.text = temporaryPinForEditing.title;
    textField_Country.text = temporaryPinForEditing.country;
    textField_Location.text = temporaryPinForEditing.location;
    textView_notes.text = temporaryPinForEditing.notes;

    // load image
    if(![temporaryPinForEditing.imageLocation isEqualToString:@""]){
        
        NSFileManager *fileManger = [NSFileManager defaultManager];
        NSURL *documentDirectory = [[fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
        NSData *imageData = [NSData dataWithContentsOfURL:[documentDirectory URLByAppendingPathComponent:[temporaryPinForEditing imageLocation] ]];
        photoImage.image = [UIImage imageWithData:imageData];
        
    }else{
        
        photoImage.image = [UIImage imageNamed:@"person"];
        
    }   
    
    // if tag is attached to pin, select that tag in the tag table / list of tags (if it is not there, it has been deleted and it will be ignored)
    
    // go thru list of all tags one by one
    for(MCTag *tagFromMasterList in listOfTags){
        
        // check to see if that tag is attached to the object
        for(MCTag *attachedTag in temporaryPinForEditing.tags){
            
            if([attachedTag.tagName isEqualToString: tagFromMasterList.tagName]){
            
                tagFromMasterList.selected = TRUE; 
                break;}
        } 
    }
    
}

-(void)storeScreenData:(CLLocationCoordinate2D)coord  // ie, grab screen data and store in temporary pin for editing
{
    // make list of selected tags
    NSMutableArray *tags = [NSMutableArray new];
    for (MCTag *z in listOfTags){
        
        if(z.selected) { [tags addObject:z]; }
    }
    
    // when exit view controller, update pin information
    [temporaryPinForEditing editLocationWithTitle:textField_Name.text  coordinate:coord location:textField_Location.text country:textField_Country.text notes:textView_notes.text imageLocation:temporaryPinForEditing.imageLocation tags:tags];

}

- (IBAction)saveButtonPressed:(id)sender {
         
    // make sure that the name and location fields are not blank
    if([textField_Name.text isEqualToString:@""] || [textField_Location.text isEqualToString:@""]){
             
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Please make sure that both the name and location fields have been completed." message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
         
    // check to make sure that the location has been checked (it looks up the long and lat coordinates, so it needs to run)
    if(![textField_Location.text isEqual:temporaryPinForEditing.location]) {
             
        UIAlertView *alert2 = [[UIAlertView alloc]initWithTitle:@"Please check the location before saving." message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert2 show];
        [self textFieldDidBeginEditing:nil];
        return;
    }
    
    // record screen data
    [self storeScreenData: temporaryPinForEditing.coordinate];
    
    // save photo
    if(rawImageFromPicker){
        
        [self savePhotoAndStoreFileName];
        
    } else if(!temporaryPinForEditing.imageLocation){
        
        temporaryPinForEditing.imageLocation = @"";
        
    }
    
    // pass pin to main controller to save and exit
    [self dismissViewControllerAnimated:YES completion:^{
             
             // completion block    
             [pointerToMainViewController addNewPinToListOfLocationsAndSave:temporaryPinForEditing originalPin:originalPin];
             [delegate refreshScreen];
         }];
         
}

-(void)savePhotoAndStoreFileName
{    
    // save photo
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSURL *documentDirectory = [[fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *fileName = [NSString stringWithFormat:@"%f",[NSDate timeIntervalSinceReferenceDate]];

    // save as a jpeg, png files do not save orientation data and will be displayed incorrectly on iPad
    NSData *imageData = UIImageJPEGRepresentation(rawImageFromPicker,1.0);
    [imageData writeToURL:[documentDirectory URLByAppendingPathComponent:fileName] atomically:YES];
    
    temporaryPinForEditing.imageLocation = fileName;

}


#pragma mark Lookup Address, Store Data, And Perform Segue

- (IBAction)checkLocationButtonPressed:(id)sender {
    
    if ([textField_Location.text isEqual:@""]) {

        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Please enter location." message:@"" delegate:self cancelButtonTitle:@"Ok"otherButtonTitles:nil, nil];
        [alert show];
        
    }else{
        
        [self getDataFromWeb];
    }
}

-(void)getDataFromWeb
{
    
    spinner.hidden = NO;
    [spinner startAnimating];
    
    NSString * str = [NSString stringWithFormat:@"%@", textField_Location.text];   
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    str = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@%&sensor=false",str];   // TURN OFF WARNING
   
    NSURL * url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
 
        //block
        [spinner stopAnimating];
        
        if(response==nil){
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No response from web services." message:@"The webserver did not understand the location you entered or you are not connected to the Internet." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
        }else{
        
            dictionaryOfWebData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&connectionError];   
            [self parseDictionaryAndSegue];
        
        }
        
    }];
    
}

-(void)parseDictionaryAndSegue {
    
    NSArray *arry = dictionaryOfWebData[@"results"];
    
    if([arry count]==0){
        
        UIAlertView *alert2 = [[UIAlertView alloc]initWithTitle:@"Please check to make sure the location is correct." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
        [alert2 show];
        return;
    }
    
    NSDictionary *dict = arry[0];
    NSString *formatedAddress = dict[@"formatted_address"];
    NSString *longitudeString = dict[@"geometry"][@"location"][@"lng"];
    NSString *latitudeString = dict[@"geometry"][@"location"][@"lat"];

    float longitude = [longitudeString floatValue];
    float latitude = [latitudeString floatValue];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);

    [self storeScreenData:coord];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Location Found" message:formatedAddress delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    [self performSegueWithIdentifier:@"toCheckMap" sender:self];
    

}



#pragma mark Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  //  if(sender == checkLocationButton){
        
        MCCheckMapViewController *mapCheck = segue.destinationViewController;
        mapCheck.locationObject = temporaryPinForEditing;
        mapCheck.pointerToMainViewController = pointerToMainViewController;
        
   // }

}

- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue
{

}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{ }];
}

- (IBAction)editImageButtonPressed:(id)sender {
 
      // empty stub             
}

     
#pragma mark Keyboard & Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField  // ie, when you hit return
{
    [self dismissKeyboard];
    return YES;
}

-(void)dismissKeyboard
{
    [textField_Name endEditing:YES];
    [textField_Location endEditing:YES];
    [textField_Country endEditing:YES];
}

// scroll out of the way of the keyboard
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    [theScrollView setContentOffset:CGPointMake(0, 130) animated:YES];

}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [theScrollView setContentOffset:CGPointMake(0, 335) animated:YES];
}



#pragma mark IMAGE PICKER

// initiate action

- (IBAction)selectedPhotoButtonPressed:(id)sender {
    
    picker = [UIImagePickerController new];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    
    [Picker dismissViewControllerAnimated:YES completion:nil];}

- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
            
    rawImageFromPicker = [info objectForKey:UIImagePickerControllerOriginalImage]; 
    photoImage.image = rawImageFromPicker;
    [Picker dismissViewControllerAnimated:YES completion:nil]; 
}

#pragma mark TableView

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"zzz"];
    
    if(!cell){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
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
        
        [listOfTags[indexPath.row] setSelected:NO];
        
    }else{
        
        [listOfTags[indexPath.row] setSelected:YES];
        
    }
    
    [tableOfTags reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    // hard coded the font (in this view controller, we are using scroll view zooming to scale, rather than doing it mathematically, so can't 
    return 1.7 * [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0].lineHeight;
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
