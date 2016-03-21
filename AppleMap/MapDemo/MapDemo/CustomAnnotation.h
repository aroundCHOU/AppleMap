//
//  CustomAnnotation.h
//  MapDemo
//
//  Created by ZhouWei on 15/12/14.
//  Copyright © 2015年 周围. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject<MKAnnotation>

//title
@property(nonatomic,copy)NSString *title;
//subtitle
@property(nonatomic,copy)NSString *subtitle;
//coordinate
@property(nonatomic,assign)CLLocationCoordinate2D coordinate;

@end
