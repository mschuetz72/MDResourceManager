//
//  MDDeviceResourceCriteria.m
//  Pods
//
//  Created by Joao Prudencio on 21/02/15.
//
//

#import "MDDeviceResourceCriteria.h"
#import <UIKit/UIKit.h>
#import "MDDeviceUtil.h"

static NSString *const kQualifierPrefixIphone = @"iphone";
static NSString *const kQualifierPrefixIpad = @"ipad";

@interface MDDeviceResourceCriteria ()

@property (nonatomic) BOOL isDevicePad;
@property (nonatomic) NSString *deviceModel;

@end

@implementation MDDeviceResourceCriteria

- (instancetype)init {

    self = [super init];

    if (self) {
        
        _isDevicePad = MDDeviceUtil.isDevicePad;
        _deviceModel = [self modelFromQualifier:[MDDeviceUtil deviceVersion]];
    }
    
    return self;
}

#pragma mark - MDResourceCriteriaProtocol

- (BOOL)meetCriteriaWith:(NSString *)qualifier {
    
    NSString *lowerCaseQualifier = [qualifier lowercaseString];

    if (![self respondsToQualifier:qualifier]) {
        
        return NO;
    }
    
    // to meet the criteria the qualifier must represent the same device.
    // if the qualifier has no specific model the criteria meets.
    // e.g. device = iphone6plus, qualifier = iphone -> YES
    //      device = iphone6plus, qualifier = iphone6 -> YES
    //      device = iphone6plus, qualifier = iphone6plus -> YES
    //      device = iphone6plus, qualifier = iphone5 -> NO

    // check if it's the same device type: iphone/ipad
    BOOL qualifierIsPad = [lowerCaseQualifier isEqualToString:kQualifierPrefixIpad];
    BOOL isEqualDevice = qualifierIsPad == self.isDevicePad;
    
    // check if it's the exact same model, or contains part of the model description.
    NSString *currentModel = [self modelFromQualifier:lowerCaseQualifier];
    NSString *deviceModel = self.deviceModel;
    BOOL containsModel = [deviceModel rangeOfString:currentModel].length > 0;
    BOOL isEqualModel = currentModel && currentModel.length > 0? containsModel: YES;
    
    return isEqualDevice && isEqualModel;
}

- (BOOL)respondsToQualifier:(NSString *)qualifier {
    
    NSString *lowerCaseQualifier = [qualifier lowercaseString];
    return [lowerCaseQualifier hasPrefix:kQualifierPrefixIphone] ||
           [lowerCaseQualifier hasPrefix:kQualifierPrefixIpad];
}

- (BOOL)shouldOverrideQualifier:(NSString *)qualifier1 withQualifier:(NSString *)qualifier2 {
    
    NSString *lowerCaseQualifier1 = [qualifier1 lowercaseString];
    NSString *lowerCaseQualifier2 = [qualifier2 lowercaseString];

    // choose the qualifier more specific
    // e.g. iphone6plus should override iphone6
    
    NSString *model1 = [self modelFromQualifier:lowerCaseQualifier1];
    NSString *model2 = [self modelFromQualifier:lowerCaseQualifier2];

    BOOL hasModel1 = model1 && model1.length > 0;
    BOOL hasModel2 = model2 && model2.length > 0;
    
    if (!hasModel1 && hasModel2) {
        
        return YES;
    } else if (hasModel1 && hasModel2 &&
               model2.length > model1.length) {
        
        return YES;
    } else {
        
        return NO;
    }
}

#pragma mark - Helper

- (NSString *)modelFromQualifier:(NSString *)qualifier {
    
    // remove ipad/iphone prefix from the qualifier.
    // we get the device model from that substring
    
    NSString *deviceDescription = @"";
    
    if ([qualifier hasPrefix:kQualifierPrefixIpad]) {
        
        deviceDescription = [qualifier substringToIndex:kQualifierPrefixIpad.length];
    } else if ([qualifier hasPrefix:kQualifierPrefixIphone]){
        
        deviceDescription = [qualifier substringToIndex:kQualifierPrefixIphone.length];
    }
    
    if ([deviceDescription isEqualToString:qualifier]) {
        
        return @"";
    } else {
        
        return [qualifier substringFromIndex:deviceDescription.length];
    }
}

- (BOOL)criteriaChangesInRuntime {
    
    return NO;
}

@end