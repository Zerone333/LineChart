//
//  YZLineChartModel.m
//  WSCloudBoardPartner
//
//  Created by MrChens on 5/1/2016.
//  Copyright © 2016 Lee. All rights reserved.
//

#import "YZLineChartModel.h"

@implementation YZLineChartModel
- (void) setData:(NSArray *)data {
    _data = data;
    _maxValue = -MAXFLOAT;
    
    for (int j = 0; j < _data.count; ++j) {
        NSNumber* number = _data[j];
        if([number floatValue] > _maxValue)
            _maxValue = [number floatValue];
    }
}
@end
