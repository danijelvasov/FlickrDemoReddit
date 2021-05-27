//
//  DetailVC.m
//  FlickrDemoReddit
//
//  Created by Danijel Vasov on 5/18/21.
//  Copyright © 2021 Danijel Vasov. All rights reserved.
//

#import "DetailVC.h"
#import "FlickrPhoto.h"
#import "FlickrNetworkHelper.h"


#define METERS_PER_MILE 1609.344

@interface DetailVC ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loader;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *largeImageView;
@property (weak, nonatomic) IBOutlet UILabel *tagsLabel;
@property (weak, nonatomic) IBOutlet UILabel *exifLabel;


@end

@implementation DetailVC

//MARK: - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupImageScrollViewAndTapToZoom];
    [self setUpAvailablePhotoData];
    [self getMediumPhoto:self.photo];
    [self getPhotoDetails:self.photo.photoId];
    [self getPhotoEXIF:self.photo.photoId];
    [self getPhotoLocation:self.photo.photoId];
    
    
    
}


//MARK: - Private methods
- (void)setupImageScrollViewAndTapToZoom {
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 6.0;
    self.scrollView.contentSize = self.largeImageView.frame.size;
    self.scrollView.delegate = self;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self.largeImageView action:@selector(doubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.largeImageView addGestureRecognizer:doubleTap];
}

- (void) doubleTap{
    //TODO: - continue here...
}


- (void) setUpAvailablePhotoData {
    self.navigationItem.title = self.photo.title;
}

- (void) getMediumPhoto: (FlickrPhoto *)photo{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *flickrImageUrl = [FlickrNetworkHelper URLStringForFlickrMediumPhoto:photo];
        NSError *err;
        NSData *imageData = [NSData dataWithContentsOfURL: [NSURL URLWithString:flickrImageUrl]options:NSDataReadingUncached error:&err];
        UIImage *largeImage = [UIImage imageWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (err) {
                NSLog(@"LARGE IMG ERROR %@", err.description);
                self.largeImageView.image = [UIImage imageNamed:@"no-img"];
            } else {
                NSLog(@"LARGE IMG OK");
                self.largeImageView.image = largeImage;
            }
        });

    });
}

- (void) getPhotoDetails: (NSString *)photoID{
    [self.loader startAnimating];
    NSString *stringUrl = [FlickrNetworkHelper URLStringForPhotoDetails:photoID];
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *err;
        NSDictionary *photoDetailsJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        NSDictionary *photoDICT = photoDetailsJSON[@"photo"];
        NSDictionary *descDICT = photoDICT[@"description"];
        NSString *description = descDICT[@"_content"];
        
        if (err) {
            NSLog(@"FAILED TO PARSE INTO JSON : %@", err);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.descriptionLabel.text = description;
            [self.loader stopAnimating];
        });
        
    }] resume];
    
}


- (void)getPhotoEXIF: (NSString *)photoID{
    NSString *stringUrl = [FlickrNetworkHelper URLStringForPhotoEXIF:photoID];
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSError *err;
        NSDictionary *photoEXIFJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        NSArray *exifArr = [photoEXIFJSON valueForKeyPath:@"photo.exif"];
        
        NSMutableString *exifInfo = [NSMutableString string];
        
        for (NSDictionary *exifDICT in exifArr) {
            NSString *tag = exifDICT[@"tag"];
            NSString *exifContent = [exifDICT valueForKeyPath:@"raw._content"];
 
            [exifInfo appendString:tag];
            [exifInfo appendString:@": "];
            [exifInfo appendString:exifContent];
            [exifInfo appendString:@", "];
            
        }

        if (err) {
            NSLog(@"FAILED TO PARSE INTO JSON : %@", err);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.exifLabel.text = exifInfo;
        });
        
    }] resume];
    
}


- (void)getPhotoLocation: (NSString *)photoID{
    NSString *stringUrl = [FlickrNetworkHelper URLStringForPhotoLocation:photoID];
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"---GOT LOCATION : %@", jsonString);
        
        NSError *err;
        NSDictionary *photoLocationJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
 
        if (err) {
            NSLog(@"FAILED TO PARSE INTO JSON : %@", err);
            return;
        }
        
        NSString *status = photoLocationJSON[@"stat"];
        
        if ([status  isEqual: @"ok"]) {
            NSDictionary *photoDICT = photoLocationJSON[@"photo"];
            CLLocationDegrees lat = [[photoDICT valueForKeyPath:@"location.latitude"] doubleValue];
            CLLocationDegrees lon = [[photoDICT valueForKeyPath:@"location.longitude"] doubleValue];
            CLLocation *photoLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self zoomMapToLocation:photoLocation];
            });
            
        } else {
            NSLog(@"---STATUS : FAIL");
            //default full map is shown
        }
        
        
        
        
    }] resume];
    
}



- (void)zoomMapToLocation: (CLLocation *)photoLocation {
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = photoLocation.coordinate.latitude;
    zoomLocation.longitude= photoLocation.coordinate.longitude;
    
    MKPointAnnotation *annotationPoint = MKPointAnnotation.new;
    annotationPoint.coordinate = zoomLocation;

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    [self.mapView setRegion: viewRegion animated:YES];
    [self.mapView addAnnotation:annotationPoint];
    
}




//MARK: - ScrollView methods
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.largeImageView;
}

- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withScale:(float)scale withCenter:(CGPoint)center {
 
    CGRect zoomRect;
 
    // The zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the
    // imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible,
    // the size of the rect grows.
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width  = scrollView.frame.size.width  / scale;
 
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
 
    return zoomRect;
}

@end
