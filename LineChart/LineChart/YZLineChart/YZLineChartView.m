//
//  YZLineChartView.m
//  WSCloudBoardPartner
//
//  Created by MrChens on 5/1/2016.
//  Copyright © 2016 Lee. All rights reserved.
//

#import "YZLineChartView.h"
#import "YZLineChartModel.h"
#import "UIView+Extension.h"

#define kLineWidth 1.f
#define kAxisPathColor [UIColor grayColor]
#define kGridPathColor [[UIColor grayColor] colorWithAlphaComponent:0.4]
#define kLabelFont [UIFont systemFontOfSize:8.f];



@interface YZLineChartView ()
@property (nonatomic, assign) CGFloat axisHeight;
@property (nonatomic, assign) CGFloat axisWidth;
@property (nonatomic, assign) CGFloat axisOriginX;
@property (nonatomic, assign) CGFloat axisOriginY;

@property (nonatomic, assign) CGFloat max;
@property (nonatomic, assign) CGFloat min;
@end

@implementation YZLineChartView

- (void)layoutSubviews
{
    
    
    // 1. 设置绘图区域的 长、宽、坐标原点  相对于self
    self.axisWidth = self.width - self.marginInset.right - self.marginInset.left;
    self.axisHeight = self.height - self.marginInset.top - self.marginInset.bottom;
    self.axisOriginX = self.marginInset.left;
    self.axisOriginY = self.height - self.marginInset.bottom;
    
    // 2. 移除self 上的所有自是福
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    // 3. 移除self layer 上的所有layer
    self.layer.sublayers = nil;
    
    // 4. 绘制网格
    [self drawGrid];
    
    // 5. 添加水平维度信息
    [self addDimensionDataLabel];
    
    // 6. 添加纵坐标点值
    [self addValueLabel];
    
    // 7. 添加各个折线的标题信息
    [self addTitleLabel];
    
    // 8. 绘制折线
    for (int i = 0; i < _chartData.count; ++i) {
        YZLineChartModel *lineChartModel = _chartData[i];
        [self strokeChartWithLineChartModel:lineChartModel];
    }
}

#pragma mark - public
/**
 *  重绘制视图
 */
- (void) reDrawLineChartWithDimensionData:(NSArray *)dimensionData chartData:(NSArray *)chartData
{
    self.dimensionData = [NSArray arrayWithArray:dimensionData];
    self.chartData = [NSArray arrayWithArray:chartData];
    
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    self.layer.sublayers = nil;
}

#pragma mark - set method

- (void)setChartData:(NSArray *)chartData
{
    _chartData = chartData;
    
    _min = MAXFLOAT;
    _max = -MAXFLOAT;
    
    for (int i = 0; i < _chartData.count; ++i) {
        YZLineChartModel *lineChartModel = _chartData[i];
        for (int j = 0; j < lineChartModel.data.count; ++j) {
            NSNumber* number = lineChartModel.data[j];
            if([number floatValue] < _min)
                _min = [number floatValue];
            
            if([number floatValue] > _max)
                _max = [number floatValue];
        }
    }
    
    _max = [self getUpperRoundNumber:_max forGridStep:_gridStep];
    
    // No data
    if(isnan(_max)) {
        _max = 1;
    }
}

#pragma mark - private

- (void)addTitleLabel
{
    UIView *tipContentView = [[UIView alloc] initWithFrame:CGRectMake(0, _axisHeight + self.marginInset.top, self.width, self.marginInset.bottom)];
    [self addSubview:tipContentView];
    
    int x = 0.f;
    UIView *lastView;
    
    for (YZLineChartModel *model in _chartData) {
        UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(x, 20.f, 14.f, 8.f)];
        tapView.backgroundColor = model.lineColor;
        [tipContentView addSubview:tapView];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = model.title;
        titleLabel.font = kLabelFont;
        [titleLabel sizeToFit];
        titleLabel.centerY = tapView.centerY;
        titleLabel.x = tapView.right + 5.f;
        titleLabel.textColor = kAxisPathColor;
        [tipContentView addSubview:titleLabel];
        
        x = titleLabel.right;
        x += 22.f;
        
        lastView = titleLabel;
    }
    tipContentView.width = lastView.right;
    tipContentView.centerX = self.centerX;
    [self setNeedsDisplay];
}

//步长值
- (void)addValueLabel
{
    for (int i = 0;  i <=_gridStep;  ++i) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0.f, 0.f)];
        label.text = [NSString stringWithFormat:@"%d", i*(int)ceilf(_max/_gridStep)];
        label.font = kLabelFont;
        [label sizeToFit];
        label.x = self.marginInset.left - label.width - 2.f;
        label.y = self.height - self.marginInset.bottom - label.height /2 - i * (self.axisHeight/_gridStep);
        label.textColor = kAxisPathColor;
        [self addSubview:label];
    }
    [self setNeedsDisplay];
}

/**
 *  添加水平维度信息
 */
- (void)addDimensionDataLabel
{
    int q = (int)_dimensionData.count;
    CGFloat width = self.axisWidth / (q - 1);
    
    for(int i=0;i<q;i++) {
        
        NSString* text = _dimensionData[i];
        CGPoint p = CGPointMake(self.axisOriginX+ i * width, self.axisOriginY + 4.f);
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(p.x, p.y, 0.f, 0.f)];
        label.text = text;
        label.font = kLabelFont;
        [label sizeToFit];
        label.x = label.x - label.width/2;
        label.textColor = kAxisPathColor;
        [self addSubview:label];
    }
    
    [self setNeedsDisplay];
    
}

/**
 *  绘制网格
 */
- (void)drawGrid
{
    //轴
    UIBezierPath *axisPath = [UIBezierPath bezierPath];
    [axisPath moveToPoint:CGPointMake(self.axisOriginX, self.axisOriginY - self.axisHeight)];
    [axisPath addLineToPoint:CGPointMake(self.axisOriginX, self.axisOriginY)];
    [axisPath addLineToPoint:CGPointMake(self.axisOriginX + self.axisWidth, self.axisOriginY)];
    
    CAShapeLayer *axisLayer = [CAShapeLayer layer];
    axisLayer.frame = self.bounds;
    axisLayer.bounds = self.bounds;
    axisLayer.path = axisPath.CGPath;
    axisLayer.strokeColor = kAxisPathColor.CGColor;
    axisLayer.fillColor = nil;
    axisLayer.lineWidth = 0.5;
    axisLayer.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:axisLayer];
    
    //辅助线
    UIBezierPath *gridPath = [UIBezierPath bezierPath];
    for (int i = 1 ; i < _gridStep; ++i) {
        [gridPath moveToPoint:CGPointMake(self.axisOriginX, self.axisOriginY - i * self.axisHeight /_gridStep)];
        [gridPath addLineToPoint:CGPointMake(self.axisOriginX + self.axisWidth, self.axisOriginY - i *self.axisHeight /_gridStep)];
    }
    
    CAShapeLayer *gridLayer = [CAShapeLayer layer];
    gridLayer.frame = self.bounds;
    gridLayer.bounds = self.bounds;
    gridLayer.path = gridPath.CGPath;
    gridLayer.strokeColor = kGridPathColor.CGColor
    ;
    gridLayer.fillColor = nil;
    gridLayer.lineWidth = 0.5;
    gridLayer.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:gridLayer];
}

/**
 *  绘制折线
 */
- (void)strokeChartWithLineChartModel:(YZLineChartModel *)lineChartModel
{
    if([_dimensionData count] == 0) {
        NSLog(@"Warning: no data provided for the chart");
        return;
    }
    
    NSArray *data = [NSArray arrayWithArray:lineChartModel.data];
    
    UIBezierPath *path = [UIBezierPath bezierPath];//折线
    UIBezierPath *noPath = [UIBezierPath bezierPath];
    UIBezierPath* fill = [UIBezierPath bezierPath];//填充色
    //    UIBezierPath* noFill = [UIBezierPath bezierPath];
    
    CGFloat scale = _axisHeight / _max;
    NSNumber* first = data[0];
    
    for(int i=1;i<data.count;i++) {
        NSNumber* startPointValue = data[i - 1];
        NSNumber* endPointValue = data[i];
        
        CGPoint p1 = CGPointMake(self.marginInset.left + (i - 1) * (_axisWidth / (data.count - 1)), _axisOriginY - [startPointValue floatValue] * scale);
        
        CGPoint p2 = CGPointMake(self.marginInset.left + i * (_axisWidth / (data.count - 1)), _axisOriginY - [endPointValue floatValue] * scale);
        
        [fill moveToPoint:p1];
        [fill addLineToPoint:p2];
        [fill addLineToPoint:CGPointMake(p2.x, _axisOriginY)];
        [fill addLineToPoint:CGPointMake(p1.x, _axisOriginY)];
        
        //        [noFill moveToPoint:CGPointMake(p1.x, _axisHeight + self.marginInset.top)];
        //        [noFill addLineToPoint:CGPointMake(p2.x, _axisHeight + self.marginInset.top)];
        //        [noFill addLineToPoint:CGPointMake(p2.x, _axisHeight + self.marginInset.top)];
        //        [noFill addLineToPoint:CGPointMake(p1.x, _axisHeight + self.marginInset.top)];
    }
    
    
    [path moveToPoint:CGPointMake(self.marginInset.left, _axisHeight + self.marginInset.top - [first floatValue] * scale)];
    
    [noPath moveToPoint:CGPointMake(self.marginInset.left, _axisHeight + self.marginInset.top)];
    
    for(int i=1;i<data.count;i++) {
        NSNumber* number = data[i];
        
        [path addLineToPoint:CGPointMake(self.marginInset.left + i * (_axisWidth / (data.count - 1)), _axisHeight + self.marginInset.top - [number floatValue] * scale)];
        [noPath addLineToPoint:CGPointMake(self.marginInset.left + i * (_axisWidth / (data.count - 1)), _axisHeight + self.marginInset.top)];
    }
    
    //填充层
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.frame = self.bounds;
    fillLayer.bounds = self.bounds;
    fillLayer.path = fill.CGPath;
    fillLayer.strokeColor = nil;
    fillLayer.fillColor = [lineChartModel.lineColor colorWithAlphaComponent:0.25].CGColor;
    fillLayer.lineWidth = 0;
    fillLayer.lineJoin = kCALineJoinRound;
    
    [self.layer addSublayer:fillLayer];
    
    
    //渐变层遮罩层
    CAGradientLayer  * gradLayer1 = [CAGradientLayer   layer ];
    gradLayer1. frame =  CGRectMake( 0,  self.marginInset.top + self.axisHeight - lineChartModel.maxValue * scale, self. frame. size. width, lineChartModel.maxValue * scale);
    [gradLayer1 setColors :[ NSArray  arrayWithObjects :( id )[[[ UIColor  whiteColor ] colorWithAlphaComponent:0.1] CGColor ],( id )[ [[ UIColor  whiteColor ] colorWithAlphaComponent:1.0] CGColor ],  nil ]];
    [gradLayer1 setLocations: @[@0.1, @0.5, @1]];
    [gradLayer1 setStartPoint :CGPointMake ( 0.5 ,  1 )];
    [gradLayer1 setEndPoint: CGPointMake( 0.5,  0)];
    [self.layer addSublayer:gradLayer1];
    fillLayer.mask = gradLayer1;
    
    
    //折线
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.frame = self.bounds;
    pathLayer.bounds = self.bounds;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = [lineChartModel.lineColor CGColor];
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = 2;
    pathLayer.lineJoin = kCALineJoinRound;
    
    [self.layer addSublayer:pathLayer];
    
    //// draw data points
    if (self.drawsDataPoints) {
        
        for(NSUInteger i = 0; i < data.count; ++i) {
            
            UIBezierPath *pointNext = [UIBezierPath bezierPath];//数据点
            
            NSNumber* number = data[i];
            [pointNext addArcWithCenter:CGPointMake(self.marginInset.left + i * (_axisWidth / (data.count - 1)), _axisHeight + self.marginInset.top - [number floatValue] * scale) radius:2.f startAngle:0.0 endAngle:180.0 clockwise:YES];
            
            CAShapeLayer *pointNextPathShapelayer = [CAShapeLayer layer];
            pointNextPathShapelayer.backgroundColor = [UIColor clearColor].CGColor;
            pointNextPathShapelayer.frame = self.bounds;
            pointNextPathShapelayer.bounds = self.bounds;
            pointNextPathShapelayer.path = pointNext.CGPath;
            pointNextPathShapelayer.strokeColor = lineChartModel.lineColor.CGColor;
            pointNextPathShapelayer.fillColor = [UIColor whiteColor].CGColor;
            pointNextPathShapelayer.lineWidth = 1.f;
            pointNextPathShapelayer.lineJoin = kCALineJoinRound;
            [self.layer addSublayer:pointNextPathShapelayer];
            
            
        }
    }
    
    
    //    CABasicAnimation *fillAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    //    fillAnimation.duration = 0.25;
    //    fillAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //    fillAnimation.fillMode = kCAFillModeForwards;
    //    fillAnimation.fromValue = (id)noFill.CGPath;
    //    fillAnimation.toValue = (id)fill.CGPath;
    //    [fillLayer addAnimation:fillAnimation forKey:@"path"];
    
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.duration = 0.25;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = (__bridge id)(noPath.CGPath);
    pathAnimation.toValue = (__bridge id)(path.CGPath);
    [pathLayer addAnimation:pathAnimation forKey:@"path"];
}

- (CGFloat)getUpperRoundNumber:(CGFloat)value forGridStep:(int)gridStep
{
    // We consider a round number the following by 0.5 step instead of true round number (with step of 1)
    CGFloat logValue = log10f(value);
    CGFloat scale = powf(10, floorf(logValue));
    CGFloat n = ceilf(value / scale * 2);
    int tmp = (int)(n) % gridStep;
    
    if(tmp != 0) {
        n += gridStep - tmp;
    }
    return n * scale / 2.0f;
}

@end
