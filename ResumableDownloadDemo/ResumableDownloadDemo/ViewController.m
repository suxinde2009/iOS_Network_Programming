//
//  ViewController.m
//  ResumableDownloadDemo
//
//  Created by su xinde on 15/5/6.
//  Copyright (c) 2015年 su xinde. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import <Foundation/Foundation.h>

@interface ViewController ()
{
    NSURLSessionDownloadTask *mDownLoadTask;
    NSData *mDownloadedData;
    NSURLSession *mSession;
    NSURLRequest *mDownloadRequest;
    UIProgressView *mProgressView;
    UIImageView *mImageView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
    
}


- (void)initUI
{
    mImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    
    mImageView.center=self.view.center;
    [self.view addSubview:mImageView];
    
    mProgressView=[[UIProgressView alloc] initWithFrame:CGRectMake(50, 200, 300, 40)];
    [self.view addSubview:mProgressView];
    
    //
    UIButton * button=[[UIButton alloc] initWithFrame:CGRectMake(50, mImageView.frame.origin.y+400+20, 50, 40)];
    button.backgroundColor=[UIColor blueColor];
    [button setTitle:@"开始" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(download) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderWidth=1;
    button.layer.borderColor=[UIColor blueColor].CGColor;
    button.layer.cornerRadius=5;
    [self.view addSubview:button];
    
    button=[[UIButton alloc] initWithFrame:CGRectMake(50+70, mImageView.frame.origin.y+400+20, 50, 40)];
    button.backgroundColor=[UIColor blueColor];
    [button setTitle:@"暂停" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderWidth=1;
    button.layer.borderColor=[UIColor blueColor].CGColor;
    button.layer.cornerRadius=5;
    [self.view addSubview:button];
    
    button=[[UIButton alloc] initWithFrame:CGRectMake(150+70, mImageView.frame.origin.y+400+20, 50, 40)];
    button.backgroundColor=[UIColor blueColor];
    [button setTitle:@"恢复" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(resume) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderWidth=1;
    button.layer.borderColor=[UIColor blueColor].CGColor;
    button.layer.cornerRadius=5;
    [self.view addSubview:button];
}


- (void) checkNet{
    //开启网络状态监控
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if(status==AFNetworkReachabilityStatusReachableViaWiFi){
            NSLog(@"当前是wifi");
        }
        if(status==AFNetworkReachabilityStatusReachableViaWWAN){
            NSLog(@"当前是3G");
        }
        if(status==AFNetworkReachabilityStatusNotReachable){
            NSLog(@"当前是没有网络");
        }
        if(status==AFNetworkReachabilityStatusUnknown){
            NSLog(@"当前是未知网络");
        }
    }];
}

- (void)download {
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    mSession= [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    //
    NSURL *url=[NSURL URLWithString:@"https://github.com/square/SocketRocket/archive/master.zip"];
    mDownloadRequest=[NSURLRequest requestWithURL:url];
    mDownLoadTask= [mSession downloadTaskWithRequest:mDownloadRequest];
    
    NSLog(@"开始加载");
    [mDownLoadTask resume];
}

- (void) pause{
    //暂停
    NSLog(@"暂停下载");
    [mDownLoadTask cancelByProducingResumeData:^(NSData *resumeData) {
        mDownloadedData=resumeData;
    }];
    mDownLoadTask=nil;
    
}
- (void)resume {
    //恢复
    NSLog(@"恢复下载");
    if(!mDownloadedData){
        NSURL *url=[NSURL URLWithString:@"https://github.com/square/SocketRocket/archive/master.zip"];
        mDownloadRequest=[NSURLRequest requestWithURL:url];
        mDownLoadTask=[mSession downloadTaskWithRequest:mDownloadRequest];
    }else{
        mDownLoadTask=[mSession downloadTaskWithResumeData:mDownloadedData];
    }
    [mDownLoadTask resume];
}

#pragma mark - delegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
//    NSURL * url=[NSURL fileURLWithPath:@"/Users/jredu/Desktop/master.zip"];
//    NSFileManager * manager=[NSFileManager defaultManager];
//    [manager moveItemAtURL:location toURL:url error:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSData * data=[manager contentsAtPath:@"/Users/jredu/Desktop/master.zip"];
//        UIImage * image=[[UIImage alloc ]initWithData:data];
//        _imageView.image=image;
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:nil message:@"下载完成" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }) ;
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    CGFloat progress=(totalBytesWritten*1.0)/totalBytesExpectedToWrite;
    dispatch_async(dispatch_get_main_queue(), ^{
        mProgressView.progress=progress;
    }) ;
}


@end
