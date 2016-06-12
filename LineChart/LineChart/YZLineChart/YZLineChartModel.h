//
//  YZLineChartModel.h
//  WSCloudBoardPartner
//
//  Created by MrChens on 5/1/2016.
//  Copyright © 2016 Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YZLineChartModel : NSObject
@property (nonatomic, copy) NSString *title;                ///<该条折现标题
@property (nonatomic, strong) UIColor *lineColor;           ///<折线颜色
@property (nonatomic, copy) NSArray *data;                  ///<折线点数据 NSNumber
@property (nonatomic, assign, readonly) CGFloat maxValue;   ///<折线最高点
@end
