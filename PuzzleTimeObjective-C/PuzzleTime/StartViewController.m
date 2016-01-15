//
//  StartViewController.m
//  PuzzleTime
//
//  Created by Wei Shan on 1/13/16.
//  Copyright © 2016 Wei Shan. All rights reserved.
//

#import "StartViewController.h"
#import "GameViewController.h"

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

//Resume the previous game
- (IBAction)ResumeGame {
    GameViewController *gameViewController = [[GameViewController alloc] initWithNibName:nil bundle:nil];
    
    gameViewController.numberPerRow = [_fileSystemPrep integerForKey:@"numberPerRow"];
    gameViewController.curItemsArray = [NSMutableArray arrayWithArray:[_fileSystemPrep objectForKey:@"_curItemsArray"]];
    gameViewController.origItemsArray = [NSMutableArray arrayWithArray:[_fileSystemPrep objectForKey:@"_origItemsArray"]];
    
    //    [self presentViewController:gameViewController animated:YES completion:NULL];
    [self.navigationController pushViewController:gameViewController animated:YES];
}

//Start a new game
- (IBAction)startGame {
    //Pick a pthoto from user's library
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:NO completion:nil];
}


//If user cancel to import the image, use the default ones and goto Game view
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    int diffLevel = roundl([_diffSlider value]);
    GameViewController *gameViewController = [[GameViewController alloc] initWithNibName:nil bundle:nil];
    gameViewController.numberPerRow = diffLevel;
    gameViewController.imageNamePrefix = @"number";
    gameViewController.imageNamePostfix = @".jpg";
    [_fileSystemPrep removeObjectForKey:@"customImage0"];
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
    gameViewController.imageNamePrefix = @"customImage";
    gameViewController.imageNamePostfix = @"";
    [self.navigationController pushViewController:gameViewController animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


//Split images and store with the key value "customImage#"
-(void)splitImage:(UIImage *)customImage numberPerRow: (NSInteger) numberPerRow UserDefaults:(NSUserDefaults *) fileSystemPrep
{
    if (customImage.size.height >= customImage.size.width) {
        
        //Height >= Width
        
        CGFloat imgWidth = customImage.size.width / numberPerRow;
        CGFloat offsetHeight = (customImage.size.height - customImage.size.width) / 2;
        
        for (int i = 0; i < numberPerRow * numberPerRow; i++) {
            CGFloat x = (i % numberPerRow) * imgWidth;
            CGFloat y = (i / numberPerRow) * imgWidth + offsetHeight;
            CGRect imgFrame = CGRectMake(x, y, imgWidth, imgWidth);
            CGImageRef imgRef = CGImageCreateWithImageInRect(customImage.CGImage, imgFrame);
            UIImage *imgPart = [UIImage imageWithCGImage:imgRef];
            NSString *imageName = [NSString stringWithFormat:@"customImage%d",i];
            [fileSystemPrep setObject:UIImagePNGRepresentation(imgPart) forKey:imageName];
        }
    } else {
        
        //Width > Height
        
        CGFloat imgWidth = customImage.size.height / numberPerRow;
        CGFloat offsetWidth = (customImage.size.width - customImage.size.height) / 2;
        for (int i = 0; i < numberPerRow * numberPerRow; i++) {
            CGFloat x = (i % numberPerRow) * imgWidth + offsetWidth;
            CGFloat y = (i / numberPerRow) * imgWidth;
            CGRect imgFrame = CGRectMake(x, y, imgWidth, imgWidth);
            CGImageRef imgRef = CGImageCreateWithImageInRect(customImage.CGImage, imgFrame);
            UIImage *imgPart = [UIImage imageWithCGImage:imgRef];
            NSString *imageName = [NSString stringWithFormat:@"customImage%d",i];
            [fileSystemPrep setObject:UIImagePNGRepresentation(imgPart) forKey:imageName];
        }
        
    }
}


//Show the difficulty level in the label
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
