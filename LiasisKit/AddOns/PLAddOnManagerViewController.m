/**
 * \file PLAddOnManagerViewController.m
 * \brief Liasis Python IDE add on manager view controller implementation.
 *
 * \details Specifies the view controller implementation for the view that 
 *          serves as the front-end for the add on manager.
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

#import "PLAddOnManagerViewController.h"

/**
 * \brief A constant NSString specifying the name of the table column identifier
 *        that should display the add on loaded/unloaded status.
 */
NSString * const PLTableViewColumnLoadStatus = @"LoadStatus";

/**
 * \brief A constant NSString specifying the name of the table column identifier
 *        that should display the add on icons.
 */
NSString * const PLTableViewColumnAddOnImage = @"AddOnImage";

/**
 * \brief A constant NSString specifying the name of the table column identifier
 *        that is should display the add on name.
 */
NSString * const PLTableViewColumnAddOnName = @"AddOnName";

/**
 * \brief A constant NSString specifying the name of the table column identifier
 *        that is should display the load button, and should change state
 *        according to the loaded/unloaded status.
 */
NSString * const PLTableViewColumnLoadButton = @"LoadButton";

@implementation PLAddOnManagerViewController


+(id)addOnViewController
{
        PLAddOnManagerViewController * controller = [[self alloc] initWithNibName:@"PLAddOnManagerViewController"
                                                                           bundle:nil];
        return [controller autorelease];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        [self loadView];
        if (self) {

        }
        return self;
}

-(void)dealloc
{
        [super dealloc];
}

#pragma mark Table View Data Source Protocol Methods

-(NSUInteger)numberOfRowsInTableView:(NSTableView *)table
{
        PLAddOnManager * manager = [PLAddOnManager defaultManager];
        return [manager numberOfAddOns];
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
        PLAddOnManager * manager = [PLAddOnManager defaultManager];
        NSString * addOnName = [[manager availableAddOns] objectAtIndex:row];
        NSString * identifier = [tableColumn identifier];
        id object = nil;
        /* Check the column identrifier to return the appropriate data */
        if ([identifier isEqualToString:PLTableViewColumnAddOnImage]) {
                object = [NSImage imageNamed:NSImageNamePreferencesGeneral];
        } else if ([identifier isEqualToString:PLTableViewColumnAddOnName]) {
                object = addOnName;
        } else if ([identifier isEqualToString:PLTableViewColumnLoadButton]) {
                if ([[manager loadedAddOns] containsObject:addOnName] == NO)
                        object = [NSNumber numberWithBool:NO];
                else
                        object = [NSNumber numberWithBool:YES];
        } else if ([identifier isEqualToString:PLTableViewColumnLoadStatus]) {
                if ([[manager loadedAddOns] containsObject:addOnName] == NO)
                        object = [NSImage imageNamed:NSImageNameStatusUnavailable];
                else if ([[[manager loadedAddOnNamed:addOnName] principalClass]
                          conformsToProtocol:@protocol(PLAddOn)])
                        object = [NSImage imageNamed:NSImageNameStatusAvailable];
                else
                        object = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
        }
        return object;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
        PLAddOnManager * manager = [PLAddOnManager defaultManager];
        NSString * addOnName;
        /* Table only allows changing the value of the load button cell */
        if ([[aTableColumn identifier] isEqualToString:PLTableViewColumnLoadButton] == NO)
                goto exit;
        addOnName = [[manager availableAddOns] objectAtIndex:rowIndex];
        /* If add on has already been loaded, does nothing */
        if ([manager didLoadAddOnWithName:addOnName])
                goto exit;
        [manager loadAddOnNamed:addOnName];
        [aTableView reloadData];
exit:
        return;
}

@end
