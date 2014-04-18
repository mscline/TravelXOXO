//
//  MCAnnotationView.m
//  CSFriends
//
//  Created by xcode on 12/2/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import "MCAnnotationView.h"

@implementation MCAnnotationView
  @synthesize backgroundFrame, photo, textField, locationToDisplay, scaleFactor, font, annotation;

-(id)initFromLocationToDisplay:(MCLocation *)loc font:(UIFont *)theFont scaleFactor:(float)scaleFact
{
    
    self = [super initWithAnnotation:locationToDisplay reuseIdentifier:@"pinImage"];
    
    if(self){
        
        locationToDisplay = loc;        
        scaleFactor = scaleFact;
        font = theFont;
        
        // create selected view / image view
        backgroundFrame = [UIView new];
        
        photo = [UIImageView new];
        textField = [UILabel new];
        
        [backgroundFrame addSubview:photo];
        [backgroundFrame addSubview:textField];
        
        [self setViewComponentsValues];
                                                                              
        [self addSubview:backgroundFrame];
                                                                              
    }    
    
    return self;

}

-(void)setViewComponentsValues
{ 

    // find the width and height of text 
    // (you can't send it your font, you have to pack its attributes in a dictionary)
    NSDictionary *fontAttributes = [NSMutableDictionary dictionaryWithObject: font forKey:NSFontAttributeName];  // NSFontAttributedName is a string/constant from Apple 
    CGSize textSize = [(NSString *)[locationToDisplay title] sizeWithAttributes: fontAttributes];
    float height = textSize.height * 2;
   
    // load photo
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSURL *documentDirectory = [[fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSData *imageData = [NSData dataWithContentsOfURL:[documentDirectory URLByAppendingPathComponent:[(MCLocation *)locationToDisplay imageLocation] ]];
    UIImage *rawImage = [UIImage imageWithData:imageData];
    
    float desiredImageWidth;
    if(rawImage){ 
        desiredImageWidth = rawImage.size.width * (height / rawImage.size.height);
    }else{
        desiredImageWidth = 0;
    }

    // scale frame/UIImageView proportionately and insert
    photo.frame = CGRectMake(0, 0, desiredImageWidth, height);  // draw correct size box
    photo.contentMode = UIViewContentModeScaleAspectFit;        // but, let Apple image inside the box
    photo.image = [UIImage imageWithData:imageData];
    photo.layer.cornerRadius = 5;
    photo.clipsToBounds = TRUE;

    // set size of MCAnnotationView (it will receive touches)    
    float internalPadding = 15;
    float fieldWidth = desiredImageWidth + 1.5*internalPadding*scaleFactor + textSize.width;
    self.frame = CGRectMake(0, 0, fieldWidth, height);
    
    //setup background frame
    backgroundFrame.frame = CGRectMake(0,0,fieldWidth, height);
    backgroundFrame.layer.cornerRadius = 5;
    backgroundFrame.layer.borderWidth = 1;
    backgroundFrame.backgroundColor =  [UIColor whiteColor]; 
    backgroundFrame.layer.borderColor = [[UIColor redColor] CGColor];  
    
    // setup textfield
    textField.frame = CGRectMake(desiredImageWidth + .75*internalPadding*scaleFactor, (height - textSize.height)/2, textSize.width  , textSize.height);
    textField.backgroundColor = [UIColor clearColor];
    textField.text = [locationToDisplay title];
    textField.font = font;
    textField.textColor = [UIColor redColor];

    annotation = locationToDisplay;
}

@end
