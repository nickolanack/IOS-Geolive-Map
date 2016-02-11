//
//  MenuViewController.h
//  GeoFormsMappit
//
//  Created by Nick Blackwell on 2013-10-22.
//  Copyright (c) 2013 Nick Blackwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MenuViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate , UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;


@property NSMutableDictionary *attributes;
@property NSMutableDictionary *details;


//-(void)takePhoto;
-(void)save;
-(void)cancel;

@property (weak, nonatomic) IBOutlet UILabel *label;

- (IBAction)onPhotoClick:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *emptyMsgLabel;
@property (weak, nonatomic) IBOutlet UIButton *emptyMsgUrl;

@property (weak, nonatomic) IBOutlet UILabel *updatingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *updatingSpinner;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)onMapButtonTap:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *startNewFormButton;

@end
