//
//  StartViewController.h
//  PuzzleTime
//
//  Created by Wei Shan on 1/13/16.
//  Copyright © 2016 Wei Shan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UISlider *diffSlider;
@property (weak, nonatomic) IBOutlet UILabel *diffLabel;
@property (weak, nonatomic) IBOutlet UIButton *resumeButton;

@property NSInteger numberPerRow;
@property NSMutableArray* curOrdered;
@property NSMutableArray* oriOrdered;
@property NSUserDefaults *fileSystemPrep;

@end
