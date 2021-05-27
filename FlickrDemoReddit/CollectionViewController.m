//
//  CollectionViewController.m
//  FlickrDemoReddit
//
//  Created by Danijel Vasov on 5/14/21.
//  Copyright © 2021 Danijel Vasov. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionViewCell.h"
#import "SearchHeaderView.h"
#import "FlickrPhoto.h"
#import "FlickrNetworkHelper.h"
#import "DetailVC.h"

@interface CollectionViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loader;

@property (strong, nonatomic) NSMutableArray<FlickrPhoto *> *flickrPhotos;
@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"resultsCell";
static NSString * const secret = @"47f48d6aeeb7d894";

NSString * searchTerm = @"";

//MARK: - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Flickr Browse";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    self.flickrPhotos = NSMutableArray.new;
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    
}

//MARK: - Private methods
- (void)fetchFlickrResults {
    [self.loader startAnimating];
    NSString *stringUrl = [FlickrNetworkHelper URLStringForSearchTerm:(searchTerm)];
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *err;
        NSDictionary *photosJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        
        if (err) {
            NSLog(@"FAILED TO PARSE INTO JSON : %@", err);
            return;
        }
        
        
        NSDictionary *photosObjJSON = photosJSON[@"photos"];
        NSArray *flickrPhotosArrayJSON = photosObjJSON[@"photo"];
        
        NSMutableArray<FlickrPhoto *> *flickrPhotos = NSMutableArray.new;
        
        for (NSDictionary *flickrPhotoDict in flickrPhotosArrayJSON) {
            NSLog(@"Photo DICT : %@", flickrPhotoDict);
            NSString *photoId = flickrPhotoDict[@"id"];
            NSString *secret = flickrPhotoDict[@"secret"];
            NSString *server = flickrPhotoDict[@"server"];
            NSNumber *farm = flickrPhotoDict[@"farm"];
            NSString *title = flickrPhotoDict[@"title"];
            
            FlickrPhoto *flickrPhoto = FlickrPhoto.new;
            flickrPhoto.photoId = photoId;
            flickrPhoto.secret = secret;
            flickrPhoto.server = server;
            flickrPhoto.farm = farm;
            flickrPhoto.title = title;
            
            [flickrPhotos addObject:flickrPhoto];
        }
        
        self.flickrPhotos = flickrPhotos;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loader stopAnimating];
            [self.collectionView reloadData];
        });
        
    }] resume];
}



-(void)pushToDetails: (FlickrPhoto*)photo{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    DetailVC * detailVC = [storyboard instantiateViewControllerWithIdentifier:@"DetailVC"];
    detailVC.photo = photo;
    [self.navigationController pushViewController:detailVC animated:true];
}



#pragma mark <UICollectionViewDataSource>

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        SearchHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SearchHeaderView" forIndexPath:indexPath];
        headerView.searchbar.placeholder = @"Enter term to search...";
        reusableview = headerView;
    }
        
    return reusableview;
}



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.flickrPhotos.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    FlickrPhoto *flickrPhoto = self.flickrPhotos[indexPath.item];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *flickrImageUrl = [FlickrNetworkHelper URLStringForFlickrThumbnail:flickrPhoto];
        NSError *err;
        NSData *imageData = [NSData dataWithContentsOfURL: [NSURL URLWithString:flickrImageUrl]options:NSDataReadingUncached error:&err];
        UIImage *thumbnailImage = [UIImage imageWithData:imageData];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (err) {
                cell.resultImage.image = [UIImage imageNamed:@"no-img"];
            } else {
                cell.resultImage.image = thumbnailImage;
            }
        });

    });
    

    return cell;
}



#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self pushToDetails:self.flickrPhotos[indexPath.row]];
}





//MARK: - Searchbar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    searchTerm = searchText;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchTerm.length > 2) {
        [self.flickrPhotos removeAllObjects];
        [self.collectionView reloadData];
        [self fetchFlickrResults];
    } else {
        [self.view endEditing:YES];
    }
}

@end
