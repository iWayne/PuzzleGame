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
    _fileSystemPrep = [NSUserDefaults standardUserDefaults];
    [self rebuildGame];
    [self saveData];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
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
        NSLog(@"IndexPath: %ld, EmptyPath: %ld", (long)indexPath.item, (long)emptySpot.item);
        NSArray *changedIndices = [NSArray arrayWithObjects:indexPath, emptySpot, nil];
        [_curItemsArray exchangeObjectAtIndex:indexPath.item withObjectAtIndex:emptySpot.item];
        [_collectionView reloadItemsAtIndexPaths: changedIndices];
    }
    
    [self checkFinished];
    [self saveData];
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

@end
