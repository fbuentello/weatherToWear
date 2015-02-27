//
//  mManager.h
//  What to Wear
//
//  Created by Fabian Buentello on 2/27/15.
//  Copyright (c) 2015 Fabian Buentello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "mCondition.h"

@import CoreLocation;

@interface mManager : NSObject<CLLocationManagerDelegate>

+ (instancetype)sharedManager;

@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) mCondition *currentCondition;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;
@property (nonatomic, strong, readonly) NSArray *dailyForecast;

- (void)findCurrentLocation;

@end
