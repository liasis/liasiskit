/**
 * \file PLAddOnManager.m
 * \brief Add on manager implementation file.
 *
 * \details Implementation file for the add on manager class.
 *
 * \copyright
 *
 * \copyright Copyright (C) 2012-2014 Jason Lomnitz and Danny Nicklas.
 *
 * This file is part of the Python Liasis IDE.
 *
 * The Python Liasis IDE is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * The Python Liasis IDE is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with the Python Liasis IDE. If not, see <http://www.gnu.org/licenses/>.
 *
 * \author Danny Nicklas.
 * \author Jason Lomnitz.
 * \date 2012-2014.
 *
 */

#import "PLAddOnManager.h"
#import "PLAddOn.h"
#import "PLAddOnExtension.h"

/**
 * \brief The global variable that holds the address of the application's 
 *        default add on manager.
 */
PLAddOnManager * PLDefaultAddOnManager;

NSString * const PLAddOnManagerDidLoadNotification = @"PLAddOnManagerDidLoad";

/**
 * \brief An NSString constant that defines the key in the plist file that
 *        corresponds to an add-on's allowed file types.
 */
NSString * const PLAddOnAllowedFileTypesName = @"Allowed file types";

/**
 * \brief An NSString constant that defines the key in the plist file that
 *        corresponds to an add-on's compatible document class.
 */
NSString * const PLAddOnDocumentClassName = @"Document class";

@implementation PLAddOnManager

#pragma mark - Object Lifecyle

+(id)defaultManager
{
        if (PLDefaultAddOnManager)
                goto exit;
        PLDefaultAddOnManager = [[self alloc] init];
exit:
        return PLDefaultAddOnManager;
}


-(id)init
{
        self = [super init];
        if (self) {
                loadedAddOns = [[NSMutableDictionary alloc] init];
                defaultExtensionForFileType = [[NSMutableDictionary alloc] init];
        }
        return self;
}

-(void)dealloc
{
        [loadedAddOns release];
        [defaultExtensionForFileType release];
        [super dealloc];
}

/**
 * \brief Release method has been overriden to avoid releasing the application
 *        -wide, default add on manager.
 */
-(oneway void)release
{
        if (self == PLDefaultAddOnManager)
                goto exit;
        [super release];
exit:
        return;
}

-(id)retain
{
        if (self == PLDefaultAddOnManager)
                goto exit;
        self = [super retain];
exit:
        return self;
}

#pragma mark -

-(NSUInteger)numberOfAddOns
{
        return [[self availableAddOns] count];
}

-(NSArray *)availableAddOns
{
        NSArray * addOns = nil;
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSBundle * mainBundle = [NSBundle mainBundle];
        addOns = [fileManager contentsOfDirectoryAtPath:[mainBundle builtInPlugInsPath]
                                                  error:nil];
        return addOns;
}

-(BOOL)didLoadAddOnWithName:(NSString *)addOnName
{
        return ([loadedAddOns objectForKey:addOnName] != nil);
}


-(NSArray *)loadedAddOns
{
        return [loadedAddOns allKeys];
}

-(NSArray *)extensionBundles
{
        Class principalClass;
        NSBundle * aBundle;
        NSMutableArray * extensions = [[NSMutableArray alloc] init];
        for (id i in [loadedAddOns allKeys]) {
                aBundle = [loadedAddOns objectForKey:i];
                principalClass = [[loadedAddOns objectForKey:i] principalClass];
                if ([principalClass conformsToProtocol:@protocol(PLAddOnExtension)] == NO)
                        continue;
                [extensions addObject:aBundle];
        }
        [extensions autorelease];
        return [NSArray arrayWithArray:extensions];
}

-(NSBundle *)loadedAddOnNamed:(NSString *)bundleName
{
        NSBundle * addOn = nil;
        addOn = [loadedAddOns objectForKey:bundleName];
        return addOn;
}

-(NSBundle *)loadAddOnNamed:(NSString *)bundleName
{
        NSArray * available = [self availableAddOns];
        NSBundle *mainBundle, * addOn = nil;
        NSString * path;
        NSError * preflightError = nil;
        NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
        NSArray * allowedTypes;
        mainBundle = [NSBundle mainBundle];
        
        path = [NSString stringWithFormat:@"%@/%@",
                [mainBundle builtInPlugInsPath],
                bundleName];
        
        if ([available containsObject:bundleName]) {
                addOn = [NSBundle bundleWithPath:path];
                [addOn preflightAndReturnError:&preflightError];
                if (preflightError) {
                        NSLog(@"Could not load bundle: %@", preflightError);
                        goto exit;
                }
                [addOn load];
                [loadedAddOns setValue:addOn forKey:bundleName];
                [notificationCenter postNotificationName:PLAddOnManagerDidLoadNotification
                                                  object:self];
                allowedTypes = [self allowedFileTypesForAddOn:addOn];
                for (NSString * type in allowedTypes) {
                        if ([defaultExtensionForFileType objectForKey:type] == nil) {
                                [defaultExtensionForFileType setValue:bundleName forKey:type];
                        }
                }
                
                if ([self defaultAddOnBundle] == nil && [[addOn principalClass] conformsToProtocol:@protocol(PLAddOnExtension)]) {
                        [self setDefaultAddOnBundle:addOn];
                }
        }
exit:
        return addOn;
}

-(NSArray *)allAllowedFileTypes
{
        NSArray * allowedTypes = nil;
        NSMutableArray * allTypes = [[NSMutableArray alloc] init];
        for (NSBundle * addOn in [loadedAddOns allValues]){
                [allTypes addObjectsFromArray:[self allowedFileTypesForAddOn:addOn]];
        }
        allowedTypes = [NSArray arrayWithArray:allTypes];
        [allTypes release];
        return allowedTypes;
}

-(NSArray *)allowedFileTypesForAddOn:(NSBundle *)addOn
{
        NSArray * fileTypes = nil;
        NSDictionary * plist = [addOn infoDictionary];
        fileTypes = [plist objectForKey:PLAddOnAllowedFileTypesName];
exit:
        return fileTypes;
}

-(Class)documentClassForAddOn:(NSBundle *)addOn
{
        Class documentClass = Nil;
        NSDictionary * plist = [addOn infoDictionary];
        NSString * documentClassName = nil;
        documentClassName = [plist objectForKey:PLAddOnDocumentClassName];
        documentClass = [[NSBundle bundleForClass:[self class]] classNamed:documentClassName];
        if (documentClass == Nil)
                documentClass = [addOn classNamed:documentClassName];
exit:
        return documentClass;
}

-(NSBundle *)defaultAddOnForFileType:(NSString *)fileType
{
        NSBundle * addOn = nil;
        NSString *bundleName = [defaultExtensionForFileType objectForKey:fileType];
        if (bundleName == nil)
                goto exit;
        addOn = [self loadedAddOnNamed:bundleName];
exit:
        return addOn;
}



@end
