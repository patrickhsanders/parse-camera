//
//  CollectionViewCell.h
//  CameraTest
//
//  Created by Aditya Narayan on 1/15/16.
//  Copyright © 2016 Aditya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *userFullName;

@end
