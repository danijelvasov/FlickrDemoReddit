//
//  DetailVC.h
//  FlickrDemoReddit
//
//  Created by Danijel Vasov on 5/18/21.
//  Copyright © 2021 Danijel Vasov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrPhoto.h"
#import "MapKit/MapKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailVC : UIViewController <MKMapViewDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) FlickrPhoto* photo;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

NS_ASSUME_NONNULL_END
