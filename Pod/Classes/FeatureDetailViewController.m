//
//  FeatureDetailViewController.m
//  GeoFormsMappit
//
//  Created by Nick Blackwell on 2015-12-04.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "FeatureDetailViewController.h"
#import "ImageUtilities.h"
#import "HTMLParser.h"
#import "GeoliveServer.h"
#import "StoredParameters.h"

@interface FeatureDetailViewController ()

@end

@implementation FeatureDetailViewController

@synthesize metadata;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *images=[HTMLParser ParseImageUrls:[metadata objectForKey:@"description"]];
    if([images count]){
        
        NSString *image=[images objectAtIndex:0];
        if([image rangeOfString:@"http" options:NSCaseInsensitiveSearch].location!=0){
            GeoliveServer *s=[GeoliveServer SharedInstance];
            image= [s.server stringByAppendingString:[@"/" stringByAppendingString:image]];
            
        }
        
        
        
        [ImageUtilities CachedImageFromUrl:image completion:^(UIImage *image){
            
            [self.imageView setImage: [ImageUtilities ThumbnailImage:image Width:200 AndHeight:200]];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onDeleteButtonTap:(id)sender {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete this photo"
                                                                   message:@"Are you sure you want to delete this marker permanently."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:deleteAction];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


@end
