//
//  mManager.m
//  What to Wear
//
//  Created by Fabian Buentello on 2/27/15.
//  Copyright (c) 2015 Fabian Buentello. All rights reserved.
//

#import "mManager.h"
#import "mClient.h"
#import <TSMessages/TSMessage.h>

@interface mManager ()

@property (nonatomic, strong, readwrite) mCondition *currentCondition;
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;
@property (nonatomic, strong, readwrite) NSArray *hourlyForecast;
@property (nonatomic, strong, readwrite) NSArray *dailyForecast;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) mClient *client;

@end

@implementation mManager

+ (instancetype)sharedManager {
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {

    if (self = [super init]) {
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        
        _client = [[mClient alloc] init];
        
        [[[[RACObserve(self, currentLocation)
            ignore:nil]
        
           // Flatten and subscribe to all 3 signals when currentLocation updates
           flattenMap:^(CLLocation *newLocation) {
               return [RACSignal merge:@[
                                         [self updateCurrentConditions],
                                         [self updateDailyForecast],
                                         [self updateHourlyForecast]
                                         ]];
        
           }] deliverOn:RACScheduler.mainThreadScheduler]
        
         subscribeError:^(NSError *error) {
             NSLog(@"error called");
             [TSMessage showNotificationWithTitle:@"Error"
                                         subtitle:@"There was a problem fetching the latest weather."
                                             type:TSMessageNotificationTypeError];
         }];
    }
    return self;
}

- (void)findCurrentLocation {
    self.isFirstUpdate = YES;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    if (self.isFirstUpdate) {
        self.isFirstUpdate = NO;
        return;
    }
    
    CLLocation *location = [locations lastObject];
    
    if (location.horizontalAccuracy > 0) {
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
    }
}

- (RACSignal *)updateCurrentConditions {
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate] doNext:^(mCondition *condition) {
        self.currentCondition = condition;
    }];
}

- (RACSignal *)updateHourlyForecast {
    return [[self.client fetchHourlyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.hourlyForecast = conditions;
    }];
}

- (RACSignal *)updateDailyForecast {
    return [[self.client fetchDailyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.dailyForecast = conditions;
    }];
}

@end
