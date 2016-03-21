//
//  LocationManager.m
//  MapDemo
//
//  Created by ZhouWei on 15/12/14.
//  Copyright © 2015年 周围. All rights reserved.
//

#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationManager ()<CLLocationManagerDelegate>

@property(nonatomic,strong)CLLocationManager *locationManager;

@end

static LocationManager *_manager = nil;

@implementation LocationManager

+(instancetype)sharedLocationManager
{
    return [[self alloc] init];
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_manager == nil) {
            _manager = [super allocWithZone:zone];
        }
    });
    return _manager;
} 

#pragma mark ----- 开始定位的方法
-(void)startLocation
{
    //定位管理类
//    CLLocationManager
    //位置信息类
//    CLLocation
    //经纬度信息
//    CLLocationCoordinate2D
    
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        //设置代理
        self.locationManager.delegate = self;
        //请求用户允许使用定位
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    //定位的精度     CoreLocation这个框架只能尽量保证定位的精度(定位的频率：每10米定位一次)
    CLLocationDistance distance = 10;
    self.locationManager.distanceFilter = distance;
    
    //定位的质量(误差)
    //定位很耗电 如果质量选择越高，耗电越快
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    //判断定位服务是否可用 并且用户是否允许定位
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        //开启定位服务，开始更新位置
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark ----- 更新了位置信息的代理方法
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"位置定位信息");
    CLLocation *location = locations.firstObject;
    if (self.updateBlock) {
        CLLocationCoordinate2D coordinate = location.coordinate;
        coordinate = [self getMarsCoorWithEarthCoor:coordinate];
        
        self.updateBlock(coordinate);
        //置空可以解决循环引用问题，但前提是保证block在调用过一次之后不再进行使用。
//        self.updateBlock = nil;         //慎用
    }
}

#pragma mark ----- 定位失败的代理方法
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"定位失败");
}

#pragma mark ----- 地理编码(根据地址获取经纬度)
-(void)getCoordinateWithAddress:(NSString *)address withFinish:(GeographyCodingBlock)finishBlock
{
    //地理编码和逆地理编码都需要通过iOS提供一个编码类 CLGeocoder
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CLPlacemark *placeMark = placemarks.firstObject;
            NSLog(@"%@",placeMark.addressDictionary);
            finishBlock(placeMark.location.coordinate);
        });
    }];
}

#pragma mark ----- 逆地理编码(根据经纬度获取地址)
-(void)getAddressWithCoordinate:(CLLocationCoordinate2D)coordinate withFinish:(unGeographyCodingBlock)finishBlock
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CLPlacemark *mark = placemarks.firstObject;
            finishBlock(mark.name);
        });
    }];
}




//不同地图使用的参照系（地球坐标，火星坐标）使用时如果位置不准确，可以用此方法转换
//CLLocationManager 这个定位的类，采用的是地球坐标系。苹果内置的高德地图 MKMapView使用的是火星坐标系
//第三方的百度地图使用的地球坐标
//第三方的高德地图使用的地球坐标
#pragma mark -火星坐标
const double pi = 3.14159265358979324;
const double a = 6378245.0;
const double ee = 0.00669342162296594323;

//将CLLocation定位的coordinate传进来，就可以计算出用于在高德地图中使用的火星坐标了
-(CLLocationCoordinate2D)getMarsCoorWithEarthCoor:(CLLocationCoordinate2D)earthCoor
{
    CLLocationCoordinate2D marsCoor;
    if (outOfChina(earthCoor.latitude, earthCoor.longitude)) {
        marsCoor = earthCoor;
        return marsCoor;
    }
    double dLat = transformLat(earthCoor.longitude-105.0, earthCoor.latitude-35.0);
    double dLon = transformLon(earthCoor.longitude-105.0, earthCoor.latitude-35.0);
    double radLat = earthCoor.latitude/180.0*pi;
    double magic = sin(radLat);
    magic = 1-ee*magic*magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
    marsCoor = CLLocationCoordinate2DMake(earthCoor.latitude+dLat, earthCoor.longitude+dLon);
    return marsCoor;
}

static bool outOfChina(double lat, double lon)
{
    if (lon < 72.004 || lon > 137.8347)
        return true;
    if (lat < 0.8293 || lat > 55.8271)
        return true;
    return false;
}

static double transformLat(double x, double y)
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return ret;
}

static double transformLon(double x, double y)
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
    return ret;
}
-(BOOL)ismainStringContainSubString:(NSString *)mainString  subString:(NSString *)subString
{
    
    NSRange range=[mainString rangeOfString:subString];
    if(range.location!=NSNotFound){
        return true;
    }else{
        return false;
    }
}


@end
