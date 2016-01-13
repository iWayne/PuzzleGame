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
    
}

- (void) viewDidAppear:(BOOL)animated{
    NSUserDefaults *fileSystemPrep = [NSUserDefaults standardUserDefaults];
    NSInteger numberPerRow = [fileSystemPrep integerForKey:@"numberPerRow"];
    if (!numberPerRow) {
        _resumeButton.enabled = NO;
    } else {
        _resumeButton.enabled = YES;
    }
}

- (IBAction)ResumeGame {
    GameViewController *gameViewController = [[GameViewController alloc] initWithNibName:nil bundle:nil];
    NSUserDefaults *fileSystemPrep = [NSUserDefaults standardUserDefaults];
    
    gameViewController.numberPerRow = [fileSystemPrep integerForKey:@"numberPerRow"];
    gameViewController.curItemsArray = [NSMutableArray arrayWithArray:[fileSystemPrep objectForKey:@"_curItemsArray"]];
    gameViewController.origItemsArray = [NSMutableArray arrayWithArray:[fileSystemPrep objectForKey:@"_origItemsArray"]];
    
    //    [self presentViewController:gameViewController animated:YES completion:NULL];
    [self.navigationController pushViewController:gameViewController animated:YES];
}

- (IBAction)startGame {
    GameViewController *gameViewController = [[GameViewController alloc] initWithNibName:nil bundle:nil];
    int diffLevel = roundl([_diffSlider value]);
    gameViewController.numberPerRow = diffLevel;
//    [self presentViewController:gameViewController animated:YES completion:NULL];
    [self.navigationController pushViewController:gameViewController animated:YES];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
