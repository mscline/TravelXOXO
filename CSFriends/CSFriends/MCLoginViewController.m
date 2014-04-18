//
//  MCLoginViewController.m
//  CSFriends
//
//  Created by xcode on 12/2/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import "MCLoginViewController.h"
#import "MCViewController.h"

@interface MCLoginViewController ()

@end

@implementation MCLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    
    [self performSegueWithIdentifier:@"toMCViewController" sender:self];

}


@end
