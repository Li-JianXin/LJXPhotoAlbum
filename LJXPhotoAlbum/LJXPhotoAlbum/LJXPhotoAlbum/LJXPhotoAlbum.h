//
//  LJXPhotoAlbum.h
//  LJXPhotoAlbum
//
//  Created by jianxin.li on 16/4/14.
//  Copyright © 2016年 m6go.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^PhotoBlock)(UIImage *image);

@interface LJXPhotoAlbum : NSObject

- (void)getPhotoAlbumOrTakeAPhotoWithController:(UIViewController *)Controller
                                   andWithBlock:(PhotoBlock)photoBlock;

@end
