//
//  UIView+Snapshot.m
//  PuzzleTime
//
//  Created by Wei Shan on 1/15/16.
//  Copyright © 2016 Wei Shan. All rights reserved.
//

#import "UIView+Snapshot.h"

@implementation UIView (Snapshot)

// It returns a customized snapshot of a given view.
- (UIView *)createSnapshot {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

@end
