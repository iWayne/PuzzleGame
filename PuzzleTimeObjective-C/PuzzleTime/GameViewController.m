//
//  GameViewController.m
//  PuzzleTime
//
//  Created by Wei Shan on 1/11/16.
//  Copyright © 2016 Wei Shan. All rights reserved.
//

#import "GameViewController.h"
#import "PuzzleCell.h"
#import "UIView+Snapshot.h"

@interface GameViewController ()

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PuzzleCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    
    [self rebuildGame];
    [self saveData];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //Attach long press gesture to collectionView
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    longPressGR.delegate = self;
    longPressGR.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:longPressGR];
    
    //Attach swipe gesture
    UISwipeGestureRecognizer *swipeLeftGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeLeftGR.delegate = self;
    swipeLeftGR.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *swipeRightGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeRightGR.delegate = self;
    swipeRightGR.direction = UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer *swipeUpGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeUpGR.delegate = self;
    swipeUpGR.direction = UISwipeGestureRecognizerDirectionUp;
    UISwipeGestureRecognizer *swipeDownGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeDownGR.delegate = self;
    swipeDownGR.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.view addGestureRecognizer:swipeLeftGR];
    [self.view addGestureRecognizer:swipeRightGR];
    [self.view addGestureRecognizer:swipeUpGR];
    [self.view addGestureRecognizer:swipeDownGR];
    
    
    
}

//Swipe Gesture
- (void) handleSwipeGesture: (UISwipeGestureRecognizer *) swipeGestureRecognizer {
    
    NSIndexPath *emptySpotIndex = [NSIndexPath indexPathForItem:[self.curItemsArray indexOfObject:@""] inSection:0];
    NSIndexPath *movedItem = nil;
    BOOL movable = NO;
    
    if (swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"swipe left");
        if ((emptySpotIndex.item + 1) % self.numberPerRow != 0) {
            movedItem = [NSIndexPath indexPathForItem:emptySpotIndex.item + 1 inSection:0];
            movable = YES;
        }
    }
    if (swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"swipe right");
        if ((emptySpotIndex.item % self.numberPerRow) != 0) {
            movedItem = [NSIndexPath indexPathForItem:emptySpotIndex.item - 1 inSection:0];
            movable = YES;
        }
    }
    if (swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        NSLog(@"swipe up");
        if ((emptySpotIndex.item + self.numberPerRow) < self.numberOfCells) {
            movedItem = [NSIndexPath indexPathForItem:emptySpotIndex.item + self.numberPerRow inSection:0];
            movable = YES;
        }
    }
    if (swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        NSLog(@"swipe down");
        if ((emptySpotIndex.item - self.numberPerRow) >= 0) {
            movedItem = [NSIndexPath indexPathForItem:emptySpotIndex.item - self.numberPerRow inSection:0];
            movable = YES;
        }
    }
    if (movable) {
        [self swapTwoItemsAndSaveStatus:emptySpotIndex secondIndexPath:movedItem];
    }
}

//Long Press
- (void) handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    CGPoint location = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    
    static UIView *snapshot = nil;
    static NSIndexPath *sourceIndexPath = nil;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            if (indexPath) {
                sourceIndexPath = indexPath;
                PuzzleCell *cell = (PuzzleCell *)[self.collectionView cellForItemAtIndexPath:sourceIndexPath];
                
                //Take a snapshot of the selected row using helper method
                snapshot = [cell createSnapshot];
                
                //Add the snapshot as subview, centered at cell's center
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.collectionView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    //Offset for gesture location.
                    center = location;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    
                    //Fade out
                    cell.alpha = 0;
                    
                } completion:^(BOOL finished) {
                }];
            }
            break;
           
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center = location;
            snapshot.center = center;
            
            //Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                //update collectionView
                [self swapTwoItemsAndSaveStatus:indexPath secondIndexPath:sourceIndexPath];
                sourceIndexPath = indexPath;
            }
            break;
        }
            
        default: {
            //Clean up
            PuzzleCell *cell = (PuzzleCell *)[self.collectionView cellForItemAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0;
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0;
                
                //Undo fade out
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
            }];
            break;
        }
            
    }

}

- (void) swapTwoItemsAndSaveStatus: (NSIndexPath *) firstIndexPath secondIndexPath: (NSIndexPath *) secondeIndexPath {
    NSLog(@"Swap first IndexPath: %ld, second IndexPath: %ld", (long)firstIndexPath.item, (long)secondeIndexPath.item);
    NSArray *changedIndices = [NSArray arrayWithObjects:firstIndexPath, secondeIndexPath, nil];
    [self.curItemsArray exchangeObjectAtIndex:firstIndexPath.item withObjectAtIndex:secondeIndexPath.item];
    [self.collectionView reloadItemsAtIndexPaths:changedIndices];
    [self checkFinished];
    [self saveData];
}


//Only used to be fimiliar with Unit Test
- (void) swapTwoItems: (NSIndexPath *) firstIndexPath secondIndexPath: (NSIndexPath *) secondeIndexPath curArray: (NSMutableArray *) curArray {
    [curArray exchangeObjectAtIndex:firstIndexPath.item withObjectAtIndex:secondeIndexPath.item];
}

//Initilize all the global value
- (void) rebuildGame {
    // Don't use self. access
    self.fileSystemPrep = [NSUserDefaults standardUserDefaults];
    
    if (!self.imageNamePrefix) {
        NSData* myEncodedImageData = [self.fileSystemPrep objectForKey:@"customImage0"];
        if (myEncodedImageData == nil) {
            self.imageNamePostfix = @".jpg";
            self.imageNamePrefix = @"number";
        } else {
            self.imageNamePrefix = @"customImage";
            self.imageNamePostfix = @"";
        }
    }
    if ([self.imageNamePostfix isEqualToString:@""]) {
        self.hasCustomImage = YES;
    } else {
        self.hasCustomImage = NO;
    }
    
    if (!self.numberPerRow) {
        self.numberPerRow = 2;
    }
    self.numberOfCells = self.numberPerRow * self.numberPerRow;
    
    //build arrays
    if (!self.origItemsArray) {
        self.origItemsArray = [self createOriginalArray:self.numberOfCells ImagePostfixName:self.imageNamePrefix ImagePostfixName:self.imageNamePostfix];
    }
    
    if (!self.curItemsArray) {
        self.curItemsArray = [self createRandomArray:self.numberOfCells OriginalArray:self.origItemsArray];
    }
    
}

//Create the original array function
- (NSMutableArray *) createOriginalArray: (NSInteger) numberOfCells ImagePostfixName: (NSString *) imageNamePrefix ImagePostfixName: (NSString *) imageNamePostfix {
    NSMutableArray *originalArray = [NSMutableArray new];
    NSString* imageName = nil;
    
    for (int i = 0; i < numberOfCells - 1; i++) {
        if (![imageNamePostfix isEqualToString:@""]) {
            imageName = [NSString stringWithFormat:@"%@%d%@", imageNamePrefix, i, imageNamePostfix];
        } else {
            imageName = [NSString stringWithFormat:@"%@%d", imageNamePrefix,i];
        }
        [originalArray addObject:imageName];
    }
    
    return originalArray;
}

//Create Random Array based on the original array
- (NSMutableArray *) createRandomArray: (NSInteger) numberOfCells OriginalArray: (NSMutableArray *) originalArray {
    NSMutableArray* validOrder = nil;
    if (numberOfCells == 4) {
        //TODO: something wrong with this block, find another way later
        BOOL isValidRandom = NO;
        NSInteger randLocInt = 0;
        NSMutableArray* oriCopy = nil;
        NSMutableArray* reverRandomOrder = nil;
        NSInteger startSearchLocInt = 0;
        
        //Avoid the reverse of the original order
        while (!isValidRandom) {
            validOrder = [[NSMutableArray alloc] init];
            randLocInt = 0;
            oriCopy = [NSMutableArray arrayWithArray:originalArray];
            
            //RandomItems
            for (NSInteger i = 0; i < numberOfCells - 1; i++) {
                randLocInt = arc4random() % [oriCopy count];
                [validOrder addObject:[oriCopy objectAtIndex:randLocInt]];
                [oriCopy removeObjectAtIndex:randLocInt];
            }
            
            //Check if reverse order
            reverRandomOrder = [NSMutableArray arrayWithArray:[[validOrder reverseObjectEnumerator] allObjects]];
            [reverRandomOrder addObjectsFromArray:reverRandomOrder];
            startSearchLocInt = [reverRandomOrder indexOfObject:[originalArray firstObject]];
            reverRandomOrder = [NSMutableArray arrayWithArray:[reverRandomOrder subarrayWithRange: NSMakeRange(startSearchLocInt, numberOfCells - 1)]];
            
            if (![reverRandomOrder isEqualToArray:originalArray]) {
                isValidRandom = YES;
            }
        }
    } else {
        validOrder = [NSMutableArray arrayWithArray:[[originalArray reverseObjectEnumerator] allObjects]];
    }
    [validOrder addObject:@""];
    return validOrder;
}

//Never called
- (void) clearHistoryData {
    self.curItemsArray = nil;
    self.origItemsArray = nil;
    [self.fileSystemPrep removeObjectForKey:@"_curItemsArray"];
    [self.fileSystemPrep removeObjectForKey:@"_origItemsArray"];
    [self.fileSystemPrep removeObjectForKey:@"numberPerRow"];
}

- (void) saveData {
    [self.fileSystemPrep setObject:self.curItemsArray forKey:@"_curItemsArray"];
    [self.fileSystemPrep setObject:self.origItemsArray forKey:@"_origItemsArray"];
    [self.fileSystemPrep setInteger:self.numberPerRow forKey:@"numberPerRow"];
    NSLog(@"Store the current status");
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.numberOfCells;
}


//Decide the size of cells
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat widthOfCell = self.collectionView.frame.size.width / (self.numberPerRow);
    return CGSizeMake(widthOfCell, widthOfCell);
}


//layout the collectionView for top/bottom/left/right paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


//Build and return puzzle cells
- (PuzzleCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PuzzleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UIImage *cellImage = nil;
    if (![self.imageNamePostfix isEqualToString:@""]) {
        cellImage = [UIImage imageNamed:self.curItemsArray[indexPath.row]];
    } else {
        NSData* myEncodedImageData = [self.fileSystemPrep objectForKey:self.curItemsArray[indexPath.row]];
        cellImage = [UIImage imageWithData:myEncodedImageData];
    }
    cell.imageView.image = cellImage;
    return cell;
}


// Move the tapped cell if it's legal
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    BOOL flagForMoving = NO;
    NSIndexPath *emptySpot = [NSIndexPath indexPathForItem:[self.curItemsArray indexOfObject:@""] inSection:0];
    
    //Empty Spot on the right, left, down, up
    if ((indexPath.item + 1) % self.numberPerRow != 0 && (indexPath.item + 1 == emptySpot.item)) {
        flagForMoving = YES;
    }else if ((indexPath.item % self.numberPerRow != 0) && (indexPath.item - 1 == emptySpot.item)) {
        flagForMoving = YES;
    } else if (indexPath.item + self.numberPerRow == emptySpot.item) {
        flagForMoving = YES;
    } else if (indexPath.item - self.numberPerRow == emptySpot.item) {
        flagForMoving = YES;
    }
    
    if (flagForMoving) {
        [self swapTwoItemsAndSaveStatus:indexPath secondIndexPath:emptySpot];
    }
    
}


//Check if user solve the puzzle

- (void) checkFinished {
    NSMutableArray* tempItems = [NSMutableArray arrayWithArray:self.origItemsArray];
    [tempItems addObject:@""];
    
    if ([tempItems isEqualToArray:self.curItemsArray]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Bingo!" message:@"You make it!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Finished. Now reload");
            self.curItemsArray = nil;
            self.origItemsArray = nil;
            [self rebuildGame];
            [self.collectionView reloadData];
            [self saveData];
            NSLog(@"Done");
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
