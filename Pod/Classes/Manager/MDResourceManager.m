//
//  ResourceManager.m
//  resources
//
//  Created by Joao Prudencio on 20/02/15.
//  Copyright (c) 2015 Joao Prudencio. All rights reserved.
//

#import "MDResourceManager.h"
#import "MDResourcePropertyListParser.h"
#import "MDOrientationResourceCriteria.h"
#import "MDDeviceResourceCriteria.h"
#import "MDResourceFilter.h"

@interface MDResourceManager ()

@property (nonatomic, strong, readonly) NSString *prefixFileName;
@property (nonatomic, strong, readonly) NSArray *criterias;

@property (nonatomic, strong) NSArray *resources;

@property (nonatomic, strong) MDResourceFilter *resourceFilter;

@property (nonatomic, strong) NSCache *cache; // not sure the filter should be the one handling a cache
@property (nonatomic) BOOL canCacheResources;

@end

@implementation MDResourceManager

#pragma mark - Initialization

- (instancetype)initWithPrefixFileName:(NSString *)fileName criterias:(NSArray *)criterias {
    
    self = [super init];
    
    if (self) {
        
        _prefixFileName = fileName;
        _criterias = criterias;
        _resourceFilter = [[MDResourceFilter alloc] initWithCriterias:criterias];
    }
    
    return self;
}

- (instancetype)initWithPrefixFileName:(NSString *)fileName {
    
    self = [super init];
    
    if (self) {
        
        _prefixFileName = fileName;
        _criterias = @[[[MDDeviceResourceCriteria alloc] init],
                       [[MDOrientationResourceCriteria alloc] init]];
        _resourceFilter = [[MDResourceFilter alloc] initWithCriterias:_criterias];
    }
    
    return self;
}

- (void)loadResources {
    
    if (!self.resources) {
        
        self.resources = [MDResourcePropertyListParser resourcesWithPrefixFileName:self.prefixFileName];
    }
}

#pragma mark - Public Fetching values

- (id)valueForKey:(NSString *)key {
    
    id value = [self cachedValueForKey:key];
    
    if (!value) {
        
        MDResource *resource = [self.resourceFilter filterResources:self.resources
                                                 forKey:key];
        
        value = resource.values[key];
        [self cacheValue:value forKey:key];
    }
    
    return value;
}

- (NSString *)stringForKey:(NSString *)key {
    
    id value = [self valueForKey:key];
    NSString *stringValue = value;
    return stringValue;
}

- (NSNumber *)numberForKey:(NSString *)key {
    
    id value = [self valueForKey:key];
    NSNumber *numberValue = value;
    return numberValue;
}

- (NSArray *)arrayForKey:(NSString *)key {
    
    id value = [self valueForKey:key];
    return [value isKindOfClass:[NSArray class]]? value: nil;
}

- (NSDictionary *)dictionaryForKey:(NSString *)key {
    
    id value = [self valueForKey:key];
    return [value isKindOfClass:[NSDictionary class]]? value: nil;
}

- (CGFloat)floatForKey:(NSString *)key {
    
    id value = [self valueForKey:key];
    
    if ([value isKindOfClass:[NSNumber class]]) {
        
        NSNumber *numberValue = value;
        return numberValue.floatValue;
    } else {
        
        return 0.0f;
    }
}

- (NSInteger)integerForKey:(NSString *)key {
    
    id value = [self valueForKey:key];
    
    if ([value isKindOfClass:[NSNumber class]]) {
        
        NSNumber *numberValue = value;
        return numberValue.integerValue;
    } else {
        
        return 0;
    }
}

- (BOOL)boolForKey:(NSString *)key {
    
    id value = [self valueForKey:key];
    
    if ([value isKindOfClass:[NSNumber class]]) {
        
        NSNumber *numberValue = value;
        return numberValue.boolValue;
    } else {
        
        return NO;
    }
}

#pragma mark - Manage cache

// TODO move this to other class

- (NSCache *)cache {
    
    if (!_cache) {
        
        _cache = [[NSCache alloc] init];
    }
    
    return _cache;
}

- (BOOL)canCacheResources {
    
    if (!_canCacheResources) {
        
        _canCacheResources = [self canCacheResourcesWithCriterias:self.criterias];
    }
    
    return _canCacheResources;
}

- (void)cacheValue:(id)value forKey:(NSString *)key {
    
    if (self.canCacheResources && value) {
        
        [self.cache setObject:value forKey:key];
    }
}

- (id)cachedValueForKey:(NSString *)key {
    
    return [self.cache objectForKey:key];
}

- (BOOL)canCacheResourcesWithCriterias:(NSArray *)criterias {
    
    // only cache when no criteria changes in run time
    
    __block BOOL canCache = YES;
    
    [criterias enumerateObjectsUsingBlock:^(id<MDResourceCriteriaProtocol> criteria, NSUInteger idx, BOOL *stop) {
        
        if ([criteria criteriaChangesInRuntime]) {
            
            canCache = NO;
            *stop = YES;
        }
    }];
    
    return canCache;
}

@end