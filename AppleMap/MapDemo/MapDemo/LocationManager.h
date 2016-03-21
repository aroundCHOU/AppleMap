//
//  LocationManager.h
//  MapDemo
//
//  Created by ZhouWei on 15/12/14.
//  Copyright © 2015年 周围. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^LOCATIONBLOCK)(CLLocationCoordinate2D coor);

//声明地理编码的block
typedef void(^GeographyCodingBlock)(CLLocationCoordinate2D coordinate);
typedef void(^unGeographyCodingBlock)(NSString *address);

@interface LocationManager : NSObject

+(instancetype)sharedLocationManager;

#pragma mark ----- 开始定位的方法
-(void)startLocation;

#pragma mark ----- 实时更新地图位置的block回调
@property(nonatomic,copy)LOCATIONBLOCK updateBlock;

#pragma mark ----- 地理编码(根据地址获取经纬度)
-(void)getCoordinateWithAddress:(NSString *)address withFinish:(GeographyCodingBlock)finishBlock;

#pragma mark ----- 逆地理编码(根据经纬度获取地址)
-(void)getAddressWithCoordinate:(CLLocationCoordinate2D)coordinate withFinish:(unGeographyCodingBlock)finishBlock;

@end
