//
//  YZLineChartView.h
//  WSCloudBoardPartner
//
//  Created by MrChens on 5/1/2016.
//  Copyright © 2016 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

//// Block definition for getting a label for a set index (use case: date, units,...)
//typedef NSString *(^WSLabelForIndexGetter)(NSUInteger index);

@interface YZLineChartView : UIView
@property (nonatomic, assign) BOOL drawsDataPoints;     ///< 这线上是否绘点
@property (nonatomic, strong) UIColor *axisColor;       ///< 坐标轴颜色
@property (nonatomic, assign) UIEdgeInsets marginInset; ///< 折线图绘制的区域
@property (nonatomic, assign) int gridStep;             ///< y坐标点数
@property (nonatomic, copy) NSArray *chartData;     //YZLineChartModel
@property (nonatomic, copy) NSArray *dimensionData; //维度值 string  xmp:一月、二月...

//@property (copy) WSLabelForIndexGetter labelForIndex;

- (void) reDrawLineChartWithDimensionData:(NSArray *)dimensionData chartData:(NSArray *)chartData;

@end
