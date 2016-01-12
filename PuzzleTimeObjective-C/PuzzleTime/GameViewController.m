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
    //Initialize
    _imageNamePostfix = @".jpg";
    _imageNamePrefix = @"number";
    _numberOfCells = 9;
    _numberPerRow = (sqrt(_numberOfCells));
    _oriOrdered = [[NSMutableArray alloc] init];
    _curOrdered = [[NSMutableArray alloc] init];
    for (int i = 0; i < _numberOfCells; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%@%d%@", _imageNamePrefix, i, _imageNamePostfix];
        [_oriOrdered addObject:imageName];
        NSLog(@"%lu", (unsigned long)_oriOrdered.count);
        NSLog(@"%@",imageName);
    }
    _curOrdered = [_oriOrdered copy];
}

- (void)viewDidAppear:(BOOL)animated{
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _numberOfCells;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    _widthOfCell = _collectionView.frame.size.width / (_numberPerRow + 1);

    return CGSizeMake(_widthOfCell, _widthOfCell);
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSInteger space = _widthOfCell / (_numberPerRow + 1) * 5 / 3;
    
    return UIEdgeInsetsMake(space, space, space, space);
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (PuzzleCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PuzzleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UIImage *cellImage = [UIImage imageNamed:_curOrdered[indexPath.row]];
    cell.imageView.image = cellImage;
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PuzzleCell *cell = (PuzzleCell*)[collectionView cellForItemAtIndexPath:indexPath];
    NSLog(@"Select %ld",(long)indexPath.row);
}



- (IBAction)showPuzzleGame:(UIButton *)sender {
//    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
//    flowLayout.itemSize = CGSizeMake(100, 100);
//    PuzzleCollectionViewController *puzzleController = [[PuzzleCollectionViewController alloc] initWithCollectionViewLayout:flowLayout];
//    [self showViewController:puzzleController sender:nil];
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
