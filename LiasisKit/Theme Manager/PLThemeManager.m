/**
 * \file PLThemeManager.m
 * \brief Liasis Python IDE theme manager implementation file.
 *
 * \details
 * This file contains the implementation for the text editor theme manager.
 * 
 * \copyright
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
 * along with Liasis. If not, see
 * <http://www.gnu.org/licenses/>.
 *
 * \author Danny Nicklas.
 * \author Jason Lomnitz.
 * \date 2012-2013.
 *
 */

#import "PLThemeManager.h"

PLThemeManager * PLDefaultThemeManager = nil;
NSString * const PLThemeManagerDidChange = @"Theme manager did change";

#pragma mark Theme Manager Keywords

NSString * const PLThemeManagerDefaultTheme = @"Solarized (Light)";

NSString * const PLThemeManagerSettings = @"Settings";

NSString * const PLThemeManagerBackground = @"background";
NSString * const PLThemeManagerForeground = @"foreground";
NSString * const PLThemeManagerLineHighlight = @"lineHighlight";
NSString * const PLThemeManagerSelection = @"selection";

#pragma mark -

@implementation PLThemeManager

/**
 * \brief Initialize the theme manager with a theme mutable dictionary instance
 *        variable.
 */
-(id)init
{
        self = [super init];
        if (self) {
                theme = [[NSMutableDictionary alloc] init];
        }
        return self;
}

/**
 * \brief Release the theme instance variable.
 */
-(void)dealloc
{
        [theme release];
        [super dealloc];
}

+(id)defaultThemeManager
{
        NSString * path;
        if (PLDefaultThemeManager == nil) {
                PLDefaultThemeManager = [[self alloc] init];
                path = [[NSBundle mainBundle] pathForResource:PLThemeManagerDefaultTheme
                                                       ofType:@"plist"];
                [PLDefaultThemeManager loadThemeAtPath:path];
        }
exit:
        return PLDefaultThemeManager;
}

/**
 * \brief Release method has been overriden to avoid releasing the application
 *        -wide, default add on manager.
 */
-(oneway void)release
{
        if (self == PLDefaultThemeManager)
                goto exit;
        [super release];
exit:
        return;
}

-(id)retain
{
        if (self == PLDefaultThemeManager)
                goto exit;
        self = [super retain];
exit:
        return self;
}

-(void)loadThemeAtPath:(NSString *)path
{
        [theme removeAllObjects];
        [theme addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:[path stringByStandardizingPath]]];
}

-(NSColor *)getThemeProperty:(NSString *)property fromGroup:(NSString *)group
{
        NSString * themePropertyString = [[theme objectForKey:group] objectForKey:property];
        NSString * hexColor = [themePropertyString stringByReplacingOccurrencesOfString:@"#" withString:@""];
        return [NSColor colorWithHexadecimalString:hexColor];
}

-(NSGradient *)selectionGradient
{
        NSColor * endColor = [self getThemeProperty:PLThemeManagerSelection fromGroup:PLThemeManagerSettings];
        NSColor * startColor = [NSColor colorWithCalibratedRed:[endColor redComponent]
                                                         green:[endColor greenComponent]
                                                          blue:[endColor blueComponent]
                                                         alpha:[endColor alphaComponent] * 0.4];
        NSGradient * gradient = [[NSGradient alloc] initWithColorsAndLocations: startColor, 0.0, endColor, 1.0, nil];
        return [gradient autorelease];
}


@end
