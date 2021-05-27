//
//  FlickrPhoto.h
//  FlickrDemoReddit
//
//  Created by Danijel Vasov on 5/17/21.
//  Copyright © 2021 Danijel Vasov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlickrPhoto : NSObject

@property (strong, nonatomic) UIImage *thumbnail;
@property (strong, nonatomic) UIImage *largeImage;

@property (strong,nonatomic) NSString *photoId;
@property (strong,nonatomic) NSString *secret;
@property (strong,nonatomic) NSString *server;
@property (strong,nonatomic) NSNumber *farm;
@property (strong,nonatomic) NSString *title;



@end

NS_ASSUME_NONNULL_END
