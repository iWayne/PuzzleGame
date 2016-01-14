//
//  ImagePickerControllerViewController.m
//  PuzzleTime
//
//  Created by Wei Shan on 1/14/16.
//  Copyright © 2016 Wei Shan. All rights reserved.
//

#import "ImagePickerController.h"

@interface ImagePickerController ()

@end

@implementation ImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.imageView.image) {
        UIImagePickerController *imagePickerController = [UIImagePickerController new];
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:NO completion:nil];
    }
    else {
        NSUserDefaults *fileSystemPrep = [NSUserDefaults standardUserDefaults];
        [fileSystemPrep setObject:self.imageView.image forKey:@"originalImage"];
        
    }
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
