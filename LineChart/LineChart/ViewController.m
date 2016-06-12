//
//  ViewController.m
//  LineChart
//
//  Created by 李艺真 on 16/6/12.
//  Copyright © 2016年 李艺真. All rights reserved.
//

#import "ViewController.h"
#import "YZLineChartView.h"
#import "YZLineChartModel.h"

@interface ViewController ()
@property (nonatomic, strong) YZLineChartView *lineChartView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.lineChartView];
    self.lineChartView.frame = CGRectMake(0, 60, self.view.bounds.size.width, 300);
    
    [self redrawLineChart];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private
- (void) redrawLineChart {
    YZLineChartModel *lineChart1 = [[YZLineChartModel alloc] init];
    lineChart1.title = @"title1";
    lineChart1.data = @[@11, @23, @33];
    lineChart1.lineColor = [UIColor redColor];
    
    YZLineChartModel *lineChart2 = [[YZLineChartModel alloc] init];
    lineChart2.title = @"title2";
    lineChart2.data = @[@111, @213, @133];
    lineChart2.lineColor = [UIColor greenColor];
    
    YZLineChartModel *lineChart3 = [[YZLineChartModel alloc] init];
    lineChart3.title = @"title3";
    lineChart3.data = @[@411, @113, @33];
    lineChart3.lineColor = [UIColor purpleColor];
    
    YZLineChartModel *lineChart4 = [[YZLineChartModel alloc] init];
    lineChart4.title = @"title4";
    lineChart4.data = @[@111, @0, @133];
    lineChart4.lineColor = [UIColor blueColor];
    
    [self.lineChartView reDrawLineChartWithDimensionData:@[@"七月", @"八月", @"九月"] chartData: @[lineChart1,lineChart2, lineChart3, lineChart4]];
    
    

}

#pragma mark - get/set method
- (UIView *)lineChartView
{
    if (_lineChartView == nil) {
        _lineChartView = [[YZLineChartView alloc] initWithFrame:CGRectZero];
        _lineChartView.axisColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _lineChartView.marginInset = UIEdgeInsetsMake(20.f, 30.f, 40.f, 30.f);
        _lineChartView.gridStep = 4;
        _lineChartView.drawsDataPoints = YES;
        _lineChartView.backgroundColor = [UIColor whiteColor];
    }
    return _lineChartView;
}

- (BOOL)shouldAutorotate {
    return YES;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    self.lineChartView.frame = self.view.bounds;
    [self redrawLineChart];
}

@end
