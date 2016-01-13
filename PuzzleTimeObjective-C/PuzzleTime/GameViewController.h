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
@property NSInteger widthOfCell;
@property NSInteger numberPerRow;
@property NSMutableArray* curOrdered;
@property NSMutableArray* oriOrdered;
@property NSString* imageNamePrefix;
@property NSString* imageNamePostfix;
@property NSUserDefaults *prefs;

@end
