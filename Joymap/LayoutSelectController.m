//
//  LayoutSelectController.m
//  Joymap
//
//  Created by faith on 2013/11/23.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "LayoutSelectController.h"

#import "Layout.h"
#import "LayoutViewController.h"

#import <NIKFontAwesomeIconFactory.h>
#import <NIKFontAwesomeIconFactory+iOS.h>

@interface LayoutSelectController ()

@end

@implementation LayoutSelectController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    DLog();
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger kind = indexPath.row + 1;
    NSString *iD = [NSString stringWithFormat:@"Layout%02ld", (long)kind];
    LayoutViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:iD];
    vc.edit = YES;
    vc.layout = Layout.new;
    vc.layout.kind = kind;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    NSString *CellIdentifier = [NSString stringWithFormat:@"Layout%02ld", indexPath.row + 1];

    cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    UIImageView *iv = (UIImageView *)[cell.contentView viewWithTag:indexPath.row + 1];
    if (iv) {
        iv.contentMode = UIViewContentModeScaleAspectFill;
        NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
        iv.image = [factory createImageForIcon:NIKFontAwesomeIconVolumeUp];
    }

    return cell;
}

@end
