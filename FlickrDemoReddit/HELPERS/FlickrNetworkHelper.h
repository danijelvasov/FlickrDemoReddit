//
//  FlickrNetworkHelper.h
//  FlickrDemoReddit
//
//  Created by Danijel Vasov on 5/18/21.
//  Copyright © 2021 Danijel Vasov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrPhoto.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlickrNetworkHelper : NSObject

+(NSString *)URLStringForSearchTerm: (NSString*) searchTerm;
+(NSString *)URLStringForFlickrThumbnail: (FlickrPhoto*) photo;
+(NSString *)URLStringForFlickrMediumPhoto: (FlickrPhoto*) photo;
+(NSString *)URLStringForPhotoDetails: (NSString*) photoId;
+(NSString *)URLStringForPhotoEXIF: (NSString*) photoId;
+(NSString *)URLStringForPhotoLocation: (NSString*) photoId;

@end

NS_ASSUME_NONNULL_END
