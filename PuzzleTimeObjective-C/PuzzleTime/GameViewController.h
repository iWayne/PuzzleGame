//
//  GameViewController.h
//  PuzzleTime
//
//  Created by Wei Shan on 1/11/16.
//  Copyright © 2016 Wei Shan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSInteger numberOfCells;
@property NSInteger numberPerRow;
@property NSMutableArray* curItemsArray;
@property NSMutableArray* origItemsArray;
@property NSString* imageNamePrefix;
@property NSString* imageNamePostfix;
@property NSUserDefaults *fileSystemPrep;

@end
