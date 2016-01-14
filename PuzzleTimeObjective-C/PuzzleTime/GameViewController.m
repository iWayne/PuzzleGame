//
//  GameViewController.m
//  PuzzleTime
//
//  Created by Wei Shan on 1/11/16.
//  Copyright © 2016 Wei Shan. All rights reserved.
//

#import "GameViewController.h"
#import "PuzzleCell.h"

@interface GameViewController ()

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"PuzzleCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    _fileSystemPrep = [NSUserDefaults standardUserDefaults];
    [self rebuildGame];
    [self saveData];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //attach long press gesture to collectionView
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:lpgr];
}

//Long Press
- (void) handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    CGPoint location = [gestureRecognizer locationInView:_collectionView];
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:location];
    
    static UIView *snapshot = nil;
    static NSIndexPath *sourceIndexPath = nil;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            if (indexPath) {
                sourceIndexPath = indexPath;
                PuzzleCell *cell = (PuzzleCell *)[_collectionView cellForItemAtIndexPath:sourceIndexPath];
                
                //Take a snapshot of the selected row using helper method
                snapshot = [self customSnapshotFromView:cell];
                
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
//                    cell.hidden = YES;
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
            PuzzleCell *cell = (PuzzleCell *)[_collectionView cellForItemAtIndexPath:sourceIndexPath];
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
    NSLog(@"before curArray: %@", _curItemsArray);
    NSLog(@"Swap first IndexPath: %ld, second IndexPath: %ld", (long)firstIndexPath.item, (long)secondeIndexPath.item);
    NSArray *changedIndices = [NSArray arrayWithObjects:firstIndexPath, secondeIndexPath, nil];
    [_curItemsArray exchangeObjectAtIndex:firstIndexPath.item withObjectAtIndex:secondeIndexPath.item];
    [_collectionView reloadItemsAtIndexPaths:changedIndices];
    [self checkFinished];
    [self saveData];
    NSLog(@"after curArray: %@", _curItemsArray);
}

//Initilize the global value
- (void) rebuildGame {
    //Initialize with Given value
    _imageNamePostfix = @".jpg";
    _imageNamePrefix = @"number";
    if (!_numberPerRow) {
        _numberPerRow = 2;
    }
    _numberOfCells = _numberPerRow * _numberPerRow;
    
    //build arrays
    if (!_origItemsArray) {
        _origItemsArray = [self createOriginalArray:_numberOfCells ImagePostfixName:_imageNamePrefix ImagePostfixName:_imageNamePostfix];
    }
    
    if (!_curItemsArray) {
        _curItemsArray = [self createRandomArray:_numberOfCells OriginalArray:_origItemsArray];
    }
    
}

//Create the original array function
- (NSMutableArray *) createOriginalArray: (NSInteger) numberOfCells ImagePostfixName: (NSString *) imageNamePrefix ImagePostfixName: (NSString *) imageNamePostfix {
    NSMutableArray *originalArray = [NSMutableArray new];
    NSString* imageName = nil;
    
    for (int i = 0; i < numberOfCells - 1; i++) {
        imageName = [NSString stringWithFormat:@"%@%d%@", imageNamePrefix, i, imageNamePostfix];
        [originalArray addObject:imageName];
    }
    
    return originalArray;
}

//Create Random Array based on the original array
- (NSMutableArray *) createRandomArray: (NSInteger) numberOfCells OriginalArray: (NSMutableArray *) originalArray {
    BOOL isValidRandom = NO;
    NSInteger randLocInt = 0;
    NSMutableArray* oriCopy = nil;
    NSMutableArray* validOrder = nil;
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
    
    [validOrder addObject:@""];
    return validOrder;
}


- (void) clearHistoryData {
    _curItemsArray = nil;
    _origItemsArray = nil;
    [_fileSystemPrep removeObjectForKey:@"_curItemsArray"];
    [_fileSystemPrep removeObjectForKey:@"_origItemsArray"];
    [_fileSystemPrep removeObjectForKey:@"numberPerRow"];
}

- (void) saveData {
    [_fileSystemPrep setObject:_curItemsArray forKey:@"_curItemsArray"];
    [_fileSystemPrep setObject:_origItemsArray forKey:@"_origItemsArray"];
    [_fileSystemPrep setInteger:_numberPerRow forKey:@"numberPerRow"];
    NSLog(@"Store the current status");
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _numberOfCells;
}


//Decide the size of cells
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat widthOfCell = _collectionView.frame.size.width / (_numberPerRow);
    
    return CGSizeMake(widthOfCell, widthOfCell);
}


//layout the collectionView for top/bottom/left/right paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (PuzzleCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PuzzleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UIImage *cellImage = [UIImage imageNamed:_curItemsArray[indexPath.row]];
    
    cell.imageView.image = cellImage;
    return cell;
}


//Move the cell with the empty one
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    BOOL flagForMoving = NO;
    NSIndexPath *emptySpot = [NSIndexPath indexPathForItem:[_curItemsArray indexOfObject:@""] inSection:0];
    
    if ((indexPath.item + 1) % _numberPerRow != 0 && (indexPath.item + 1 == emptySpot.item)) {
        flagForMoving = YES;
    } else if ((indexPath.item % _numberPerRow != 0) && (indexPath.item - 1 == emptySpot.item)) {
        flagForMoving = YES;
    } else if (indexPath.item + _numberPerRow == emptySpot.item) {
        flagForMoving = YES;
    } else if (indexPath.item - _numberPerRow == emptySpot.item) {
        flagForMoving = YES;
    }
    
    if (flagForMoving) {
        [self swapTwoItemsAndSaveStatus:indexPath secondIndexPath:emptySpot];
    }
    
}


//Check if user solve the puzzle
- (void) checkFinished {
    NSMutableArray* tempItems = [NSMutableArray arrayWithArray:_origItemsArray];
    [tempItems addObject:@""];
    
    if ([tempItems isEqualToArray:_curItemsArray]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Bingo!" message:@"You make it!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Finished. Now reload");
            _curItemsArray = nil;
            _origItemsArray = nil;
            [self rebuildGame];
            [_collectionView reloadData];
            [self saveData];
            NSLog(@"Done");
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

// Add this at the end of your .m file. It returns a customized snapshot of a given view.
- (UIView *)customSnapshotFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
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
