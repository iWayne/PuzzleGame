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
    [self.collectionView registerNib:[UINib nibWithNibName:@"PuzzleCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];

//    [self.collectionView registerClass:[PuzzleCell class] forCellWithReuseIdentifier:@"Cell"];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 30;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (PuzzleCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PuzzleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.cellLabel.text = [NSString stringWithFormat:@"cell %li",(long)indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PuzzleCell *cell = (PuzzleCell*)[collectionView cellForItemAtIndexPath:indexPath];
    NSArray *views = [cell.contentView subviews];
    UILabel *label = [views objectAtIndex:0];
    NSLog(@"Select %@",label.text);
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
