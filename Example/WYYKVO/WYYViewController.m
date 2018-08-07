//
//  WYYViewController.m
//  WYYKVO
//
//  Created by wangyaoyao on 08/07/2018.
//  Copyright (c) 2018 wangyaoyao. All rights reserved.
//

#import "WYYViewController.h"
#import "NSObject+WYKVO.h"
#import "WYWebViewController.h"
#import "Person.h"

@interface WYYViewController ()
@property (nonatomic, strong) Person *person;

@end

@implementation WYYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.person = [[Person alloc]init];
    
    [self.person wy_addObserver:self forKey:NSStringFromSelector(@selector(age)) changeBlock:^(id  _Nonnull observer, NSString * _Nonnull key, id oldValue, id newValue) {
        NSLog(@"------基础数据类型------\n observer----%@\n key-----%@\n oldValue------%@\n newValue-------%@", observer, key, oldValue, newValue);
    }];
    
    [self.person wy_addObserver:self forKey:NSStringFromSelector(@selector(name)) changeBlock:^(id  _Nonnull observer, NSString * _Nonnull key, id oldValue, id newValue) {
        NSLog(@"------对象数据类型-------\n observer----%@\n key-----%@\n oldValue------%@ \n newValue------%@\n", observer, key, oldValue, newValue);
    }];
    
    
    [self.person wy_addObserver:self forKey:NSStringFromSelector(@selector(isBoy)) changeBlock:^(id  _Nonnull observer, NSString * _Nonnull key, id oldValue, id newValue) {
        NSLog(@"------对象数据类型-------\n observer----%@\n key-----%@\n oldValue------%@ \n newValue------%@\n", observer, key, oldValue, newValue);
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(changeBaseDataValue) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(100, 100, 150, 100);
    [btn setTitle:@"基础数据类型监听" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 addTarget:self action:@selector(changeObjectDataValue) forControlEvents:UIControlEventTouchUpInside];
    btn1.frame = CGRectMake(100, 250, 150, 100);
    [btn1 setTitle:@"对象数据类型监听" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 addTarget:self action:@selector(changeBoolDataValue) forControlEvents:UIControlEventTouchUpInside];
    btn2.frame = CGRectMake(100, 400, 150, 100);
    [btn2 setTitle:@"Bool类型监听" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn3 addTarget:self action:@selector(showWebView) forControlEvents:UIControlEventTouchUpInside];
    btn3.frame = CGRectMake(100, 500, 150, 100);
    [btn3 setTitle:@"webView" forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btn3];
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)showWebView
{
    WYWebViewController *webView = [[WYWebViewController alloc]init];
    [self presentViewController:webView animated:YES completion:nil];
}

- (void)changeBaseDataValue
{
    //注意数据源应要是对象，基础类型报错
    //    NSArray *names = @[@"Jame", @"Lili", @"Youyou"];
    //    NSArray *ages = @[[NSNumber numberWithInteger:20],[NSNumber numberWithInteger:10],[NSNumber numberWithInteger:18],[NSNumber numberWithInteger:30]];
    NSArray *ages = @[@20,@10,@18,@30];
    
    NSUInteger index = arc4random_uniform((u_int32_t)ages.count);
    
    self.person.age = [ages[index] intValue];
    //    self.person.name = names[index];
    
}
- (void)changeObjectDataValue
{
    //注意数据源应要是对象，基础类型报错
    NSArray *names = @[@"Jame", @"Lili", @"Youyou"];
    //    NSArray *ages = @[[NSNumber numberWithInteger:20],[NSNumber numberWithInteger:10],[NSNumber numberWithInteger:18],[NSNumber numberWithInteger:30]];
    
    NSUInteger index = arc4random_uniform((u_int32_t)names.count);
    
    self.person.name = names[index];
}

- (void)changeBoolDataValue
{
    NSArray *sexs = @[@YES, @NO];
    NSUInteger index = arc4random_uniform((u_int32_t)sexs.count);
    self.person.isBoy = [sexs[index] boolValue];
}

-(void)dealloc
{
    [self.person wy_removeObserver:self forKey:NSStringFromSelector(@selector(name))];
    [self.person wy_removeObserver:self forKey:NSStringFromSelector(@selector(age))];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
