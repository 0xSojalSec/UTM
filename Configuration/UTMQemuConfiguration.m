//
// Copyright © 2019 osy. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "UTMQemuConfiguration.h"
#import "UTMQemuConfiguration+Constants.h"
#import "UTMQemuConfiguration+Defaults.h"
#import "UTMQemuConfiguration+Display.h"
#import "UTMQemuConfiguration+Drives.h"
#import "UTMQemuConfiguration+Miscellaneous.h"
#import "UTMQemuConfiguration+Networking.h"
#import "UTMQemuConfiguration+Sharing.h"
#import "UTMQemuConfiguration+System.h"
#import "UTM-Swift.h"

const NSString *const kUTMConfigSystemKey = @"System";
const NSString *const kUTMConfigDisplayKey = @"Display";
const NSString *const kUTMConfigInputKey = @"Input";
const NSString *const kUTMConfigNetworkingKey = @"Networking";
const NSString *const kUTMConfigPrintingKey = @"Printing";
const NSString *const kUTMConfigSoundKey = @"Sound";
const NSString *const kUTMConfigSharingKey = @"Sharing";
const NSString *const kUTMConfigDrivesKey = @"Drives";
const NSString *const kUTMConfigDebugKey = @"Debug";
const NSString *const kUTMConfigInfoKey = @"Info";
const NSString *const kUTMConfigVersionKey = @"ConfigurationVersion";

const NSInteger kCurrentConfigurationVersion = 2;

@interface UTMQemuConfiguration ()

@property (nonatomic, readonly) NSMutableDictionary *rootDict;

@end

@implementation UTMQemuConfiguration {
    NSMutableDictionary *_rootDict;
}

@synthesize rootDict = _rootDict;

- (void)setName:(NSString *)name {
    [self propertyWillChange];
    _name = name;
}

- (void)setExistingPath:(NSURL *)existingPath {
    [self propertyWillChange];
    _existingPath = existingPath;
}

- (void)setSelectedCustomIconPath:(NSURL *)selectedCustomIconPath {
    [self propertyWillChange];
    _selectedCustomIconPath = selectedCustomIconPath;
}

#pragma mark - Migration

- (void)migrateConfigurationIfNecessary {
    [self migrateMiscellaneousConfigurationIfNecessary];
    [self migrateDriveConfigurationIfNecessary];
    [self migrateNetworkConfigurationIfNecessary];
    [self migrateSystemConfigurationIfNecessary];
    [self migrateDisplayConfigurationIfNecessary];
    [self migrateSharingConfigurationIfNecessary];
    self.version = @(kCurrentConfigurationVersion);
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self resetDefaults];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary name:(NSString *)name path:(NSURL *)path {
    self = [super init];
    if (self) {
        [self reloadConfigurationWithDictionary:dictionary name:name path:path];
    }
    return self;
}

#pragma mark - Dictionary representation

- (NSDictionary *)dictRepresentation {
    return (NSDictionary *)_rootDict;
}

- (NSURL*)terminalInputOutputURL {
    NSURL* tmpDir = [[NSFileManager defaultManager] temporaryDirectory];
    NSString* ioFileName = [NSString stringWithFormat: @"%@.terminal", self.name];
    NSURL* ioFile = [tmpDir URLByAppendingPathComponent: ioFileName];
    return ioFile;
}

- (void)resetDefaults {
    [self propertyWillChange];
    _rootDict = [@{
        kUTMConfigSystemKey: [NSMutableDictionary new],
        kUTMConfigDisplayKey: [NSMutableDictionary new],
        kUTMConfigInputKey: [NSMutableDictionary new],
        kUTMConfigNetworkingKey: [NSMutableDictionary new],
        kUTMConfigPrintingKey: [NSMutableDictionary new],
        kUTMConfigSoundKey: [NSMutableDictionary new],
        kUTMConfigSharingKey: [NSMutableDictionary new],
        kUTMConfigDrivesKey: [NSMutableArray new],
        kUTMConfigDebugKey: [NSMutableDictionary new],
        kUTMConfigInfoKey: [NSMutableDictionary new],
    } mutableCopy];
    self.version = @(kCurrentConfigurationVersion);
    [self loadDefaults];
}

- (void)reloadConfigurationWithDictionary:(NSDictionary *)dictionary name:(NSString *)name path:(NSURL *)path {
    [self propertyWillChange];
    _rootDict = CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (__bridge CFDictionaryRef)dictionary, kCFPropertyListMutableContainers));
    self.name = name;
    self.existingPath = path;
    self.selectedCustomIconPath = nil;
    [self migrateConfigurationIfNecessary];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[UTMQemuConfiguration alloc] initWithDictionary:_rootDict name:self.name path:self.existingPath];
}

#pragma mark - Settings

- (void)setVersion:(NSNumber *)version {
    [self propertyWillChange];
    self.rootDict[kUTMConfigVersionKey] = version;
}

- (NSNumber *)version {
    return self.rootDict[kUTMConfigVersionKey];
}

@end
