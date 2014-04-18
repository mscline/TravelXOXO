//
//  MCCheckMapViewController.m
//  CSFriends
//
//  Created by xcode on 11/27/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import "MCCheckMapViewController.h"
#import "UIViewController+ResizingForDifferentDevices.h"
#import "MCViewController.h"
#import "MCAppDelegate.h"

@interface MCCheckMapViewController ()

  @property (strong, nonatomic) IBOutlet MKMapView *theMap;
  @property (strong, nonatomic) IBOutlet UILabel *textLabelA;
  @property (strong, nonatomic) IBOutlet UILabel *textLabelB;
  @property (strong, nonatomic) IBOutlet UIButton *buttonBack;

@end

@implementation MCCheckMapViewController
  @synthesize locationObject, theMap, textLabelA, textLabelB, pointerToMainViewController, buttonBack;


- (void)viewDidLoad
{
    [super viewDidLoad];

    theMap.delegate = self;

    theMap.frame = CGRectMake(0, self.view.frame.size.height * .09, self.view.frame.size.width, self.view.frame.size.height * .5);
    
    // set region
    MKCoordinateRegion reg = MKCoordinateRegionMake(locationObject.coordinate, MKCoordinateSpanMake(.5, .5));
    [theMap setRegion:reg];
    
    // add pin
    [theMap addAnnotation:locationObject];
    
    // resize text
    [self changeFontSizeForButtonsAndLabels:[NSMutableArray arrayWithObject:textLabelA] fontSize:[pointerToMainViewController returnFontBig] scaleFactorToConvertSizesFromIPhoneToIPad:[pointerToMainViewController returnScaleFactor]];
    
    [self changeFontSizeForButtonsAndLabels:[NSMutableArray arrayWithObject:textLabelB] fontSize:[pointerToMainViewController returnFontBig] scaleFactorToConvertSizesFromIPhoneToIPad:[pointerToMainViewController returnScaleFactor]];

    [self changeFontSizeForButtonsAndLabels:[NSMutableArray arrayWithObject:buttonBack] fontSize:[pointerToMainViewController returnFontBig] scaleFactorToConvertSizesFromIPhoneToIPad:[pointerToMainViewController returnScaleFactor]];
    
    [self spaceObjectsEvenlyAlongXAxis:[NSMutableArray arrayWithObject:textLabelA]];
    [self spaceObjectsEvenlyAlongXAxis:[NSMutableArray arrayWithObject:textLabelB]];
    
    
    // set text label's y position (the position was moved when resized text, but positioning not optimal)
    textLabelA.frame = CGRectMake(textLabelA.frame.origin.x, theMap.frame.origin.y + theMap.frame.size.height + 25 * [pointerToMainViewController returnScaleFactor],textLabelA.frame.size.width, textLabelA.frame.size.height);  
    textLabelB.frame = CGRectMake(textLabelB.frame.origin.x, textLabelA.frame.origin.y + textLabelA.frame.size.height +  5 * [pointerToMainViewController returnScaleFactor], textLabelB.frame.size.width, textLabelB.frame.size.height);  
    
    // unhide screen objects
    theMap.hidden = FALSE;
    buttonBack.hidden = FALSE;
    textLabelA.hidden = FALSE;
    textLabelB.hidden = FALSE;
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
