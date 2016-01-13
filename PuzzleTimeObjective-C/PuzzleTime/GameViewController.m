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
    // Do any additional setup after loading the view.
    [_collectionView registerNib:[UINib nibWithNibName:@"PuzzleCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    _prefs = [NSUserDefaults standardUserDefaults];
    [self rebuildGame];
    [self saveData];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void) rebuildGame {
    //Initialize with Given value
    _imageNamePostfix = @".jpg";
    _imageNamePrefix = @"number";
    if (!_numberPerRow) {
        _numberPerRow = 2;
    }
    _numberOfCells = _numberPerRow * _numberPerRow;
    
    
    //build arrays
    if (!_oriOrdered) {
        [self buildOriItems];
    }
    if (!_curOrdered) {
        [self buildRandomItems];
    }
    //TODO: Create start data
}

- (void) buildOriItems {
    _oriOrdered = [[NSMutableArray alloc] init];
    for (int i = 0; i < _numberOfCells - 1; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%@%d%@", _imageNamePrefix, i, _imageNamePostfix];
        [_oriOrdered addObject:imageName];
    }
}

- (void) buildRandomItems {
    BOOL isValidRandom = NO;
    
    //Avoid the reverse of the original order
    while (!isValidRandom) {
        _curOrdered = [[NSMutableArray alloc] init];
        NSInteger randLocInt = 0;
        NSMutableArray* tempItems = [NSMutableArray arrayWithArray:_oriOrdered];
        for (NSInteger i = 0; i < _numberOfCells - 1; i++) {
            randLocInt = arc4random() % [tempItems count];
            [_curOrdered addObject:[tempItems objectAtIndex:randLocInt]];
            [tempItems removeObjectAtIndex:randLocInt];
        }
        tempItems = [NSMutableArray arrayWithArray:[[_curOrdered reverseObjectEnumerator] allObjects]];
        if (![tempItems isEqualToArray:_oriOrdered]) {
            isValidRandom = YES;
        }
    }
    [_curOrdered addObject:@""];
}


- (void) clearHistory {
    _curOrdered = nil;
    _oriOrdered = nil;
    //Delete stored data
}

- (void) saveData {
    [_prefs setObject:_curOrdered forKey:@"curOrdered"];
    [_prefs setObject:_oriOrdered forKey:@"oriOrdered"];
    [_prefs setInteger:_numberPerRow forKey:@"numberPerRow"];
    NSLog(@"Store the current status");
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _numberOfCells;
}


//Decide the size of cells
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (!_widthOfCell) {
    CGFloat widthOfCell = _collectionView.frame.size.width / (_numberPerRow);
//    }
    
    return CGSizeMake(widthOfCell, widthOfCell);
}

//layout the collectionView for top/bottom/left/right paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSInteger space = _widthOfCell / (_numberPerRow + 1);
    
    return UIEdgeInsetsMake(space, space, space, space);
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (PuzzleCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PuzzleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UIImage *cellImage = [UIImage imageNamed:_curOrdered[indexPath.row]];
    cell.imageView.image = cellImage;
    return cell;
}


//Move the cell with the empty one
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSIndexPath *emptySpot = [NSIndexPath indexPathForItem:[_curOrdered indexOfObject:@""] inSection:0];
    BOOL flagForMoving = NO;
    
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
        NSLog(@"IndexPath: %ld, EmptyPath: %ld", (long)indexPath.item, (long)emptySpot.item);
        NSArray *changedIndices = [NSArray arrayWithObjects:indexPath, emptySpot, nil];
        [_curOrdered exchangeObjectAtIndex:indexPath.item withObjectAtIndex:emptySpot.item];
        [_collectionView reloadItemsAtIndexPaths: changedIndices];
    }
    
    [self checkFinished];
    [self saveData];
}


//Check if user solve the puzzle
- (void) checkFinished {
    NSMutableArray* tempItems = [NSMutableArray arrayWithArray:_oriOrdered];
    [tempItems addObject:@""];
    
    if ([tempItems isEqualToArray:_curOrdered]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Bingo!" message:@"You make it!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Finished. Now reload");
            _curOrdered = nil;
            _oriOrdered = nil;
            [self rebuildGame];
            [_collectionView reloadData];
            [self saveData];
            NSLog(@"Done");
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
