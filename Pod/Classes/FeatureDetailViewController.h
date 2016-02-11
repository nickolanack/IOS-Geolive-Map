//
//  FeatureDetailViewController.h
//  GeoFormsMappit
//
//  Created by Nick Blackwell on 2015-12-04.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeatureDetailViewController : UIViewController

@property  NSDictionary *metadata;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)onDeleteButtonTap:(id)sender;


@end
