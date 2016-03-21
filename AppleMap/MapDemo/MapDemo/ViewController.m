//
//  ViewController.m
//  MapDemo
//
//  Created by ZhouWei on 15/12/14.
//  Copyright © 2015年 周围. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "LocationManager.h"
#import "CustomAnnotation.h"

@interface ViewController ()<MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UITextField *insertTextField;

@end

@implementation ViewController
//地图展示使用的框架是MapKit
//定位功能使用的框架是CLLocation(CoreLocation)


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //显示当前用户位置
    self.mapView.showsUserLocation = YES;
    
    self.mapView.delegate = self;
    
    //实现定位回调的block
    [LocationManager sharedLocationManager].updateBlock = ^(CLLocationCoordinate2D coor){
        //把定位好的位置信息传递给MKMapView
        MKCoordinateRegion region;
        //设置位置的中心点
        region.center = coor;
        //span这个值也是一个结构体，它决定了中心点周围信息展示的范围
        MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
        region.span = span;
        //把位置信息传递给mapView
        [self.mapView setRegion:region animated:YES]; 
    };
}

#pragma mark ----- 搜索按钮点击事件
- (IBAction)searchButtonDidClicked:(id)sender {
    [[LocationManager sharedLocationManager] getCoordinateWithAddress:self.insertTextField.text withFinish:^(CLLocationCoordinate2D coordinate) {
        //在这里得到编码后的经纬度
        //插放大头针：苹果需要开发者自己写一个NSObject的子类，而且这个类只要遵守MKAnimation这个协议即可
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500);
        [self.mapView setRegion:region animated:YES];
        
        //给指定位置插放一枚大头针
        CustomAnnotation *annotation = [[CustomAnnotation alloc] init];
        annotation.title = @"a";
        annotation.subtitle = @"b";
        annotation.coordinate = coordinate;
        //最后把大头针添加到地图上
        [self.mapView addAnnotation:annotation];
    }];
    
//    //测试逆地理编码
//    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(40, 116);
//    [[LocationManager sharedLocationManager] getAddressWithCoordinate:coordinate withFinish:^(NSString *address) {
//        NSLog(@"%@",address);
//    }];
}

//#pragma mark ----- 自定义大头针的代理方法
//-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
//{
//    if ([[annotation title] isEqualToString:@"a"]) {
//        MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"flag"];
//        if (view == nil) {
//            view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"flag"];
//        }
//        view.image = [UIImage imageNamed:@"liyang.jpg"];
//        return view;
//    }
//    return nil;
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
