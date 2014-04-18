//
//  AttributeConfigurator.h
//  GettingStuffWorking
//
//  Created by Bobby Ren on 6/26/12.
//  Copyright (c) 2012 Harvard University. All rights reserved.
//

#import <Foundation/Foundation.h>
#define USE_ATTRIBUTE_CONFIGURATOR 1
// must be the same format and parameters as NSLocalizedStringWithDefaultValue for genstrings to work
// but inserts a call to attributeForProperty
// to create strings file, use: genstrings -s ConfiguredAttribute -o en.lproj *.m
#define ConfiguredAttributeWithDefaultValue(key, table, bundle, default, comment) [AttributeConfigurator attributeForProperty:key orLocalizedDefault:NSLocalizedStringWithDefaultValue(key, nil, [NSBundle mainBundle], default, comment)]
@interface AttributeConfigurator : NSObject
{
    NSString * uniqueDeviceID;
    NSMutableDictionary * attributes;
}

@property (nonatomic, retain) NSString * uniqueDeviceID;
@property (nonatomic, retain) NSMutableDictionary * attributes;

+(AttributeConfigurator *) sharedAttributeConfigurator;
+(void)initializeAttributesFromServer;
+(NSString*)getUUID;
+(NSMutableDictionary *) getAttributes;
+(id) attributeForProperty:(NSString*)property;
+(id) attributeForProperty:(NSString *)property orLocalizedDefault:(id)defaultValue;
@end
