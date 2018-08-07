//
//  WYWebViewController.m
//  CustomKVODemo
//
//  Created by yao wang on 2018/8/7.
//  Copyright © 2018年 yao wang. All rights reserved.
//

#import "WYWebViewController.h"

@interface WYWebViewController ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) NSString *url;
@end

@implementation WYWebViewController

#pragma mark - ==========  life cycle  ==========

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc]initWithFrame:self.view.frame];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    
    _url = @"http://v.douyin.com/eCB88y/";
//    NSString *str = @"https://www.baidu.com";
    
    [self loadWebView];

    // Do any additional setup after loading the view.
}

- (void)loadWebView
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_url]];
    [_webView loadRequest:request];

}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString containsString:@"https://itunes.apple.com"]) {
        _url = request.URL.absoluteString;
        [self webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
   
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ==========  event response  ==========

#pragma mark - ==========  private method  ==========

#pragma mark - ==========  delegate  ==========
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - ==========  setter  ==========

#pragma mark - ==========  getter  ==========


@end
