//
//  AttributeConfigurator.m
//  GettingStuffWorking
//
//  Created by Bobby Ren on 6/26/12.
//  Copyright (c) 2012 Harvard University. All rights reserved.
//
//  to generate Localizable.strings file, use command line command:
//    genstrings -o en.lproj *.m
//  this creates/recreates Localizable.strings. However, for some reason
//  when it gets copied to a different language version, the white space 
//  (carriage returns) need to be retyped or the simulator doesn't find it.
//
//  usage of attribute configurator should be:
//  check if there's a configured text for a key
//  if server has provided one use that
//  if none, use the NS_LocalizedStringWithDefaultValue for that key
//  
//  to make it easier for the developer, the macro C_onfiguredAttributeWithDefaultValue was created
//  so genstrings will be able to find it. It will convert all text in the code with C_onfiguredAttribute to NS_LocalizedString
//  then try to match the parameters, so C_onfiguredAttributeWithDefaultValue must have 5 parameters:
//  (Key, nil, nil, DefaultValue, Comment)
//  In this paragraph, there is a _ after the C so that genstrings doesn't try to translate the above lines.

#import "AttributeConfigurator.h"

static AttributeConfigurator *sharedAttributeConfigurator;

@implementation AttributeConfigurator

@synthesize uniqueDeviceID;
@synthesize attributes;

#pragma mark Singleton
+(AttributeConfigurator*)sharedAttributeConfigurator 
{
    if (!sharedAttributeConfigurator){
        sharedAttributeConfigurator = [[AttributeConfigurator alloc] init];
    }
    return sharedAttributeConfigurator;
}

-(id)init {
    self = [super init];
    
    /*** device id on pasteboard ***/
    UIPasteboard *appPasteBoard = [UIPasteboard pasteboardWithName:@"com.Gympact.App.Pasteboard" create:YES];
    appPasteBoard.persistent = YES;
    uniqueDeviceID = [appPasteBoard string];    
    if (uniqueDeviceID == nil) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        uniqueDeviceID = (__bridge_transfer NSString *)CFUUIDCreateString(NULL,uuidRef);
        CFRelease(uuidRef);
        [appPasteBoard setString:uniqueDeviceID];
        NSLog(@"Unique device created and set to pasteboard: %@", uniqueDeviceID);
    }
    else {
        NSLog(@"Unique device retrieved from pasteboard: %@", uniqueDeviceID);
    }
    
    /*** create default attributes dictionary or get it from pList ***/
    attributes = [[NSMutableDictionary alloc] init];
    
    // initialize alternate attributes - must be done outside of init or infinite loop happes
    //[AttributeConfigurator initializeAttributesFromServer];
    
    // hack: create alternate attributes locally
    [self createDefaultConfigurableAttributes];
    
    // todo: load default attributes and saved version of attributes from disk
    
    return self;
}

-(void)initializeAttributesFromServer {
    // request attributes from server
    // must be done after first sharedAttributeConfigurator is initialized
    //NSLog(@"Get attributes from server for device %@", [AttributeConfigurator getUUID]);
    NSLog(@"Not getting attributes from server for device %@", [AttributeConfigurator getUUID]);
    
    //attributes = [ASIHHTTPRequest requestFromServerForDeviceID:uniqueDeviceID];
}

+(NSString*)getUUID {
    return [[AttributeConfigurator sharedAttributeConfigurator] uniqueDeviceID];
}

+(NSMutableDictionary *) getAttributes {    
    return [[AttributeConfigurator sharedAttributeConfigurator] attributes];
}

+(id) attributeForProperty:(NSString*)property {
    // this does a dumb search for a default value
    id attribute = [[[AttributeConfigurator sharedAttributeConfigurator] attributes] objectForKey:property];
    NSLog(@"Getting attribute for property: %@ = %@", property, attribute);
    if (attribute == nil) {
        // last resort, search in localized string for that property; has no default
        // value if that property is missing
        // 
        return [[NSBundle mainBundle] localizedStringForKey:property value:@"" table:nil];
    }
    return attribute;
}

+(id) attributeForProperty:(NSString *)property orLocalizedDefault:(id)defaultValue {
    // recommended usage: includes a localized string that uses the same key
    // [AttributeConfigurator attributeForProperty:@"MyKey" orDefault:NS_LocalizedStringWithDefault(@"ExampleKey", @"Localizable" or nil, [NSBundle mainBundle], @"Example English default value for this ExampleKey", @"Example comment for genstrings")]
    // because this way genstrings can still create the Localizable.strings file
    // and uses the same keys as we expect for the configurable attributes, and the user
    // can still add an English default value
    // This default value is calculated outside of AttributeConfigurator so the parameter
    // defaultValue is the already evaluated, localized NSString
    
    // for shorthand, use the macro CONFIGURED_ATTRIBUTE
    
    // do not make a call to [attributeForProperty:] because it will bypass defaultValue
    id attribute = [[[AttributeConfigurator sharedAttributeConfigurator] attributes] objectForKey:property];

    if (!attribute)
        return defaultValue;
    return attribute;
}

-(void)createDefaultConfigurableAttributes {
    // HACK:
    // defaults for all user-facing strings in case there is nothing provided by the server for a specific key
    // in attributeForProperty, the key is first matched against the dictionary sent by the server
    // if that doesn't exist, this list will be used

    NSString * key;
    NSString * value;

    // fake defaults from server!
    key = @"YesLabel";
    value = @"WOOHOO";
    [attributes setValue:value forKey:key];

    key = @"NoLabel";
    value = @"HELL NAW";
    [attributes setValue:value forKey:key];
}
@end
