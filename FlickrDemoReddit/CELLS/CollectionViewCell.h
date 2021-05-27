//
//  CollectionViewCell.h
//  FlickrDemoReddit
//
//  Created by Danijel Vasov on 5/14/21.
//  Copyright © 2021 Danijel Vasov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *resultImage;
@property (weak, nonatomic) IBOutlet UILabel *cellText;



@end

NS_ASSUME_NONNULL_END
