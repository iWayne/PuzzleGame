//
//  ImagePickerControllerViewController.h
//  PuzzleTime
//
//  Created by Wei Shan on 1/14/16.
//  Copyright © 2016 Wei Shan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePickerController : UIImagePickerController <UIImagePickerControllerDelegate, UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end
