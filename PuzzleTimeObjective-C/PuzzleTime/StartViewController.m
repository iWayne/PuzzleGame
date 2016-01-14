//
//  StartViewController.m
//  PuzzleTime
//
//  Created by Wei Shan on 1/13/16.
//  Copyright © 2016 Wei Shan. All rights reserved.
//

#import "StartViewController.h"
#import "GameViewController.h"
#import "ImagePickerController.h"

@interface StartViewController ()

@end

@implementation StartViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _fileSystemPrep = [NSUserDefaults standardUserDefaults];
}

- (void) viewDidAppear:(BOOL)animated{
    NSInteger numberPerRow = [_fileSystemPrep integerForKey:@"numberPerRow"];
    if (!numberPerRow) {
        _resumeButton.enabled = NO;
    } else {
        _resumeButton.enabled = YES;
    }
}

- (IBAction)ResumeGame {
    GameViewController *gameViewController = [[GameViewController alloc] initWithNibName:nil bundle:nil];
    
    gameViewController.numberPerRow = [_fileSystemPrep integerForKey:@"numberPerRow"];
    gameViewController.curItemsArray = [NSMutableArray arrayWithArray:[_fileSystemPrep objectForKey:@"_curItemsArray"]];
    gameViewController.origItemsArray = [NSMutableArray arrayWithArray:[_fileSystemPrep objectForKey:@"_origItemsArray"]];
    
    //    [self presentViewController:gameViewController animated:YES completion:NULL];
    [self.navigationController pushViewController:gameViewController animated:YES];
}

- (IBAction)startGame {
    //Pick a pthoto from user's library
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:NO completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    int diffLevel = roundl([_diffSlider value]);
    GameViewController *gameViewController = [[GameViewController alloc] initWithNibName:nil bundle:nil];
    gameViewController.numberPerRow = diffLevel;
    [self.navigationController pushViewController:gameViewController animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Handle the user's image and transform to game view
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];

    //Split Images
    int diffLevel = roundl([_diffSlider value]);
    if (image) {
        [self splitImage:image numberPerRow:diffLevel UserDefaults:_fileSystemPrep];
    }
    
    //Start a Puzzle game
    GameViewController *gameViewController = [[GameViewController alloc] initWithNibName:nil bundle:nil];
    gameViewController.numberPerRow = diffLevel;
    [self.navigationController pushViewController:gameViewController animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
//    NSData* myEncodedImageData2 = [_fileSystemPrep objectForKey:@"customImage0"];
//    image22 = [UIImage imageWithData:myEncodedImageData2];
    
}


//TODO: Consider other size of images
-(void)splitImage:(UIImage *)customImage numberPerRow: (NSInteger) numberPerRow UserDefaults:(NSUserDefaults *) fileSystemPrep
{
    if (customImage.size.height < customImage.size.width) {
        return;
    }
    
    UIImage* image22 = nil;
    
    CGFloat imgWidth = customImage.size.width / numberPerRow;
    CGFloat offsetHeight = (customImage.size.height - customImage.size.width) / 2;
    
    for (int i = 0; i < numberPerRow * numberPerRow; i++) {
        CGFloat x = (i % numberPerRow) * imgWidth;
        CGFloat y = (i / numberPerRow) * imgWidth + offsetHeight;
        CGRect imgFrame = CGRectMake(x, y, imgWidth, imgWidth);
        CGImageRef imgRef = CGImageCreateWithImageInRect(customImage.CGImage, imgFrame);
        UIImage *imgPart = [UIImage imageWithCGImage:imgRef];
//        [customImages addObject:imgPart];
//        CGImageRelease(imgRef);
//        NSData *imageData = UIImagePNGRepresentation(imgPart);
//        NSData *myEncodedImageData = [NSKeyedArchiver archivedDataWithRootObject:imageData];
        NSString *imageName = [NSString stringWithFormat:@"customImage%d",i];
        [fileSystemPrep setObject:UIImagePNGRepresentation(imgPart) forKey:imageName];
        
        
    }
}


- (IBAction)changeDiff:(UISlider *)sender {
    // Set the label text to the value of the slider as it changes
    int discreteValue = roundl([sender value]);
    [sender setValue:(float)discreteValue];
    switch (discreteValue) {
        case 2:
            _diffLabel.text = @"Easy";
            break;
        case 3:
            _diffLabel.text = @"Normal";
            break;
        case 4:
            _diffLabel.text = @"Really Hard!";
            break;
        default:
            break;
    }
}

@end
