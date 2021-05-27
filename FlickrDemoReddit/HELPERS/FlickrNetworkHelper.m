//
//  FlickrNetworkHelper.m
//  FlickrDemoReddit
//
//  Created by Danijel Vasov on 5/18/21.
//  Copyright © 2021 Danijel Vasov. All rights reserved.
//

#import "FlickrNetworkHelper.h"

@implementation FlickrNetworkHelper

static NSString * const apiKey = @"fbbe840a0ef0e7505a2361551e357240";

+(NSString *)URLStringForSearchTerm: (NSString*) searchTerm {
    NSString * searchTrimmed = [searchTerm stringByReplacingOccurrencesOfString:@"\\s+" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, searchTerm.length)];
   
    NSString * stringUrl = [NSString stringWithFormat:@"https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&text=%@&per_page=100&format=json&nojsoncallback=1", apiKey, searchTrimmed];
    
    return stringUrl;
}


+(NSString *)URLStringForFlickrThumbnail: (FlickrPhoto*) photo {
    NSString * stringUrl = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_s.jpg", photo.farm, photo.server, photo.photoId, photo.secret];
    
    return stringUrl;
}


+(NSString *)URLStringForFlickrMediumPhoto: (FlickrPhoto*) photo {
    NSString * stringUrl = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_m.jpg", photo.farm, photo.server, photo.photoId, photo.secret];
    
    return stringUrl;
}


+(NSString *)URLStringForPhotoDetails: (NSString*) photoId {
    NSString * stringUrl = [NSString stringWithFormat:@"https://www.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=%@&photo_id=%@&format=json&nojsoncallback=1", apiKey, photoId];
    
    return stringUrl;
}

+(NSString *)URLStringForPhotoEXIF: (NSString*) photoId {
    NSString * stringUrl = [NSString stringWithFormat:@"https://www.flickr.com/services/rest/?method=flickr.photos.getExif&api_key=%@&photo_id=%@&format=json&nojsoncallback=1", apiKey, photoId];
    
    return stringUrl;
}

+(NSString *)URLStringForPhotoLocation: (NSString*) photoId {
    NSString * stringUrl = [NSString stringWithFormat:@"https://www.flickr.com/services/rest/?method=flickr.photos.geo.getLocation&api_key=%@&photo_id=%@&format=json&nojsoncallback=1", apiKey, photoId];
    
    return stringUrl;
}



@end
