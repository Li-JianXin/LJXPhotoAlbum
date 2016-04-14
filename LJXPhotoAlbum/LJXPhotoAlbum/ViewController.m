//
//  ViewController.m
//  LJXPhotoAlbum
//
//  Created by jianxin.li on 16/4/14.
//  Copyright © 2016年 m6go.com. All rights reserved.
//

#import "ViewController.h"
#import "LJXPhotoAlbum.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) LJXPhotoAlbum      *photoAlbum;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _photoAlbum = [[LJXPhotoAlbum alloc]init];
}

- (IBAction)takePhotoClick:(id)sender {
    [_photoAlbum getPhotoAlbumOrTakeAPhotoWithController:self andWithBlock:^(UIImage *image) {
        self.imageView.image = image;
    }];
}

@end
