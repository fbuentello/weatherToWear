//
//  mDailyForecast.m
//  What to Wear
//
//  Created by Fabian Buentello on 2/27/15.
//  Copyright (c) 2015 Fabian Buentello. All rights reserved.
//

#import "mDailyForecast.h"

@implementation mDailyForecast

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    // 1
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    // 2
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    // 3
    return paths;
}

@end
