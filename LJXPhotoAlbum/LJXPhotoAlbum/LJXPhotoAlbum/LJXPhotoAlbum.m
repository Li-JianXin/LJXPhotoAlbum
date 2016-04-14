//
//  LJXPhotoAlbum.m
//  LJXPhotoAlbum
//  GitHub:https://github.com/Li-JianXin/LJXPhotoAlbum
//  博客:http://www.jianshu.com/p/be40c92dd10f
//  Created by jianxin.li on 16/4/14.
//  Copyright © 2016年 m6go.com. All rights reserved.
//

#import "LJXPhotoAlbum.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define ScreenF [UIScreen mainScreen].bounds
#define ScreenW ScreenF.size.width
#define ScreenH ScreenF.size.height
#define IOS8 [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0

@interface LJXPhotoAlbum ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate>

@property (nonatomic, copy) PhotoBlock photoBlock;
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) UIViewController        *viewController;
@end

@implementation LJXPhotoAlbum

- (instancetype)init {
    if ([super init]) {
        _picker = [[UIImagePickerController alloc]init];
    }
    return self;
}

- (void)getPhotoAlbumOrTakeAPhotoWithController:(UIViewController *)viewController andWithBlock:(PhotoBlock)photoBlock {
    self.photoBlock = photoBlock;
    self.viewController = viewController;
    if (IOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"图片" message:@"选择" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *photoAlbumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self getAlertActionType:1];
        }];
        
        UIAlertAction *cemeraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self getAlertActionType:2];
        }];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self getAlertActionType:0];
        }];
        [alertController addAction:photoAlbumAction];
        [alertController addAction:cancleAction];
        if ([self imagePickerControlerIsAvailabelToCamera]) {
            [alertController addAction:cemeraAction];
        }
        [self.viewController presentViewController:alertController animated:YES completion:nil];
    } else {
        UIActionSheet *actionSheet;
        if([self imagePickerControlerIsAvailabelToCamera]){
            actionSheet  = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
        }else{
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择", nil];
        }
        [actionSheet showInView:self.viewController.view];
    }
    
    
}

- (void)getAlertActionType:(NSInteger)type {
    NSInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    switch (type) {
        case 1:
        {
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
            break;
        case 2:
        {
            sourceType = UIImagePickerControllerSourceTypeCamera;
        }
            break;
        case 0:
        {
            return;
        }
            break;
            
        default:
            break;
    }
    [self creatUIImagePickerControllerWithAlertActionType:sourceType];
    
}


#pragma mark - ActionSheet Delegte
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if([self imagePickerControlerIsAvailabelToCamera]){
        switch (buttonIndex){
            case 0:
            {
                sourceType = UIImagePickerControllerSourceTypeCamera;
            }
                break;
            case 1:
            {
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                
            }
                break;
            case 2:
                return;
        }
    } else {
        switch (buttonIndex) {
            case 0:
            {
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
                break;
                
            default:
                break;
        }
    }
    [self creatUIImagePickerControllerWithAlertActionType:sourceType];
    
    
}


#pragma mark -  创建ImagePickerController
- (void)creatUIImagePickerControllerWithAlertActionType:(NSInteger)type {
    NSInteger sourceType = type;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        if (![self AVAuthorizationStatusIsGranted]) {
            
            if (IOS8) {
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"相机未授权" message:@"请到设置-隐私-相机中修改" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    return;
                }];
                [alertController addAction:comfirmAction];
                [self.viewController presentViewController:alertController animated:YES completion:nil];
                
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"相机未授权" message:@"请到设置-隐私-相机中修改" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            
        }
        
    }
    
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.delegate = self;
    self.picker.allowsEditing = YES;
    self.picker.sourceType = sourceType;
    [self.viewController presentViewController:self.picker animated:YES completion:nil];
}


// 判断硬件是否支持拍照
- (BOOL)imagePickerControlerIsAvailabelToCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - 照机授权判断
- (BOOL)AVAuthorizationStatusIsGranted  {
    __block BOOL isGranted = NO;
    //判断是否授权相机
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    switch (authStatus) {
        case 0: { //第一次使用，则会弹出是否打开权限
            [AVCaptureDevice requestAccessForMediaType : AVMediaTypeVideo completionHandler:^(BOOL granted) {
                //授权成功
                if (granted) {
                    isGranted = YES;
                }
                else{
                    isGranted = NO;
                }
            }];
        }
            break;
        case 1:{
            //还未授权
            isGranted = NO;
        }
            break;
        case 2:{
            //主动拒绝授权
            isGranted = NO;
        }
            break;
        case 3: {
            //已授权
            isGranted = YES;
        }
            break;
            
        default:
            break;
    }
    return isGranted;
    
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //获取编辑后的图片
    UIImage *image = info[@"UIImagePickerControllerEditedImage"];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    NSLog(@"DELEGATE %@",image);
    if (self.photoBlock) {
        self.photoBlock(image);
    }
    [_picker dismissViewControllerAnimated:YES completion:nil];
}

// 取消选择照片:
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"取消图片选择");
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}


@end
