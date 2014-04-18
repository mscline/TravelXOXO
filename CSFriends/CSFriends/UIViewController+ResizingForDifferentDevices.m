//
//  UIViewController+ResizingForDifferentDevices.m
//  CSFriends
//
//  Created by xcode on 1/1/14.
//  Copyright (c) 2014 xcode. All rights reserved.
//

#import "UIViewController+ResizingForDifferentDevices.h"

@implementation UIViewController (ResizingForDifferentDevices)

// note: if not resizing properly, make sure that you deselect resize subviews in the right pane

-(void)changeFontSizeForButtonsAndLabels:(NSMutableArray *)listOfAllTextItems fontSize:(UIFont *)newFont scaleFactorToConvertSizesFromIPhoneToIPad:(float)scaleFactorToConvertSizesFromIPhoneToIPad
{

    // change font size and set frame
    for(id item in listOfAllTextItems){
       
        //NSLog(@"%@", item);
        
        if([item isKindOfClass:[UILabel class]]){

            UILabel *labelItem = (UILabel *)item;
            
            // change font
            labelItem.font = newFont;
            
            // find height and width of text (you can't send it your font, you have to pack its attributes in a dictionary)
            NSDictionary *fontAttributes = [NSMutableDictionary dictionaryWithObject: newFont forKey:NSFontAttributeName];  // NSFontAttributedName is a string/constant from Apple 
            CGSize textSize = [(NSString *)labelItem.text sizeWithAttributes: fontAttributes];
            
            float textFieldWidth = textSize.width;
            float textFieldHeight = textSize.height;
            
            // set height and width (alternatively, could use  drawWithRect:options:attributes: which gives various options)
            labelItem.frame = CGRectMake(labelItem.frame.origin.x, 
                                         labelItem.frame.origin.y * scaleFactorToConvertSizesFromIPhoneToIPad, 
                                         textFieldWidth, 
                                         textFieldHeight);
            
            
        } else if([item isKindOfClass:[UIButton class]]){
            
            UIButton *button = (UIButton *)item;
            
            // change font
            button.titleLabel.font = newFont;

            // find height and width of text (you can't send it your font, you have to pack its attributes in a dictionary)
            NSDictionary *fontAttributes = [NSMutableDictionary dictionaryWithObject: newFont forKey:NSFontAttributeName];  // NSFontAttributedName is a string/constant from Apple 
            CGSize textSize = [(NSString *)button.titleLabel.text sizeWithAttributes: fontAttributes];
            
            // if is an image, it should be centered up/down in frame
            //   (rem: frame.origin will return position within superview)
            
            if(textSize.width == 0){ 
                
                button.frame = CGRectMake(button.frame.origin.x, 
                                          button.frame.origin.y * scaleFactorToConvertSizesFromIPhoneToIPad, 
                                          button.frame.size.width * scaleFactorToConvertSizesFromIPhoneToIPad,
                                          button.frame.size.height * scaleFactorToConvertSizesFromIPhoneToIPad);
                
            } else {
                
                // else it is text
                float textFieldWidth = textSize.width;
                float textFieldHeight = textSize.height;
                
                // set height and width (alternatively, could use  drawWithRect:options:attributes: which gives various options)
                button.frame = CGRectMake(button.frame.origin.x, 
                                          button.frame.origin.y * scaleFactorToConvertSizesFromIPhoneToIPad, 
                                          textFieldWidth, 
                                          textFieldHeight);
            }
            

        } else if([item isKindOfClass:[UITextField class]]){
     
            // for UITextView, just multiply container times scale factor
            // and change font
            // (clips to bounds in storyboard must be off and turn off autoresize, or get scale done twice)
            
            UITextView *labelItem = (UITextView *)item;
            
            labelItem.font = newFont;
            labelItem.frame = CGRectMake(labelItem.frame.origin.x * scaleFactorToConvertSizesFromIPhoneToIPad, 
                                         labelItem.frame.origin.y * scaleFactorToConvertSizesFromIPhoneToIPad, 
                                         labelItem.frame.size.width * scaleFactorToConvertSizesFromIPhoneToIPad, 
                                         labelItem.frame.size.height * scaleFactorToConvertSizesFromIPhoneToIPad);
            
        } else if([item isKindOfClass:[UITextView class]]){
        
            // may wish to add to category
        
        }else{
    
            // just move position
            UIView *mscItem = (UIView *)item;
            mscItem.frame = CGRectMake(mscItem.frame.origin.x * scaleFactorToConvertSizesFromIPhoneToIPad, 
                                         mscItem.frame.origin.y * scaleFactorToConvertSizesFromIPhoneToIPad, 
                                         mscItem.frame.size.width * scaleFactorToConvertSizesFromIPhoneToIPad, 
                                         mscItem.frame.size.height * scaleFactorToConvertSizesFromIPhoneToIPad);
        }
        
    }
    


}

-(void)spaceObjectsEvenlyAlongXAxis:(NSMutableArray *)subviews
{
 
    // sort based on x-position
    [subviews sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        if( [(UIView *)obj1 frame].origin.x < [(UIView *)obj2 frame].origin.x ){
            
            return -1;
            
        }else{
            
            return 1;
            
        }
        
    }];
    
    // find width of all buttons in view
    float widthOfAllButtonsInView = 0;
    
    for(UIView *z in subviews) {
        
        widthOfAllButtonsInView = widthOfAllButtonsInView + z.frame.size.width;
        
    }
    
    // calculate how much padding you need to distribute evenly (the number of gaps = n + 1)
    float padding = (self.view.frame.size.width - widthOfAllButtonsInView) / ([subviews count] + 1);
    
    // position views/labels/buttons
    float xPosition = padding;
    
    for(int x = 0; x < 1000; x++){       // loop does not initiate exit
        
        UIView *currentItem = [subviews objectAtIndex: x]; 
        
        currentItem.frame = CGRectMake(xPosition, currentItem.frame.origin.y, currentItem.frame.size.width, currentItem.frame.size.height);
        
        if(x == [subviews count] - 1){  return; }
        
        xPosition = xPosition + currentItem.frame.size.width + padding;
        
    }

}

/*

note: ht of a label/box with size 12 font is roughly 14
 
Autoresizing does not mean that the subview will take up the size of its superview. It just means that it will resize relative to the size change of its superview whenever the superview's bounds change. So initially, you have to set the size of the subview to the correct value. The autoresizing mask will then deal with size changes in the future.

textView = [[UITextView alloc] initWithFrame:self.view.bounds];
[textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight]
*/

@end
