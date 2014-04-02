/**
 * \file PLNavigationPopUpButton.m
 * \brief Liasis Python IDE navigation NSPopUpButton subclass.
 *
 * \details This file contains the implementation for a navigation popup button.
 *          The navigation popup button is a NSPopUpButton subclass that
 *          primarily relates ranges in source code to titles, providing
 *          functionality for the user to navigate the source.
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
 * along with Liasis. If not, see <http://www.gnu.org/licenses/>.
 *
 * \author Danny Nicklas.
 * \author Jason Lomnitz.
 * \date 2012-2014.
 *
 * \see PLNavigationDataSource
 */

#import "PLNavigationPopUpButton.h"

/**
 * \brief Return an array of navigation ranges sorted by their location.
 *
 * \details Sort the array of ranges (encapsulated in NSValues) by their
 *          location in ascending order.
 *
 * \return A sorted NSArray of ranges encapsulated in NSValues.
 */
NSArray * sortNavigationRanges(NSArray * ranges)
{
        return [ranges sortedArrayUsingComparator:^NSComparisonResult(NSValue * obj1, NSValue * obj2) {
                if ([obj1 rangeValue].location < [obj2 rangeValue].location)
                        return NSOrderedAscending;
                else if ([obj1 rangeValue].location > [obj2 rangeValue].location)
                        return NSOrderedDescending;
                else
                        return NSOrderedSame;
        }];
}

@implementation PLNavigationPopUpButton

/**
 * \brief Initialize the navigation popup button.
 *
 * \details Use the initialize method to initialize the popup button.
 *
 * \return The initialized navigation popup button.
 */
-(id)initWithFrame:(NSRect)frameRect
{
        self = [super initWithFrame:frameRect];
        if (self)
                [self initialize];
        return self;
}

/**
 * \brief Initialize the navigation popup button.
 *
 * \details Use the initialize method to initialize the popup button.
 */
-(void)awakeFromNib
{
        if ([super respondsToSelector:@selector(awakeFromNib)])
                [super awakeFromNib];
        [self initialize];
}

/**
 * \brief Initialize the navigation popup button.
 *
 * \details Set the action for clicking menu items to the clickMenuItem: method
 *          of this class. Set the navigation popup button cell to not use items
 *          menu items for its title. Instead, its title menu item is set
 *          explicitly to one of noNavigationMenuItem, noSelectionMenuItem, or
 *          the selected item in the menu.
 */
-(void)initialize
{
        [self setTarget:self];
        [self setAction:@selector(clickMenuItem:)];
        [[self cell] setUsesItemFromMenu:NO];
        noNavigationMenuItem = [[NSMenuItem alloc] initWithTitle:@"No navigation items to display"
                                                             action:NULL
                                                      keyEquivalent:@""];
        noSelectionMenuItem = [[NSMenuItem alloc] initWithTitle:@"No selection"
                                                         action:NULL
                                                  keyEquivalent:@""];
        [self reloadData];
}

/**
 * \brief Deallocate the navigation popup button.
 *
 * \details Clear the navigation popup button cell (in case it is using one of
 *          the no Navigation or No Selection menu items) and release both menu
 *          item instance variables.
 */
-(void)dealloc
{
        [[self cell] setMenuItem:nil];
        [noNavigationMenuItem release];
        [noSelectionMenuItem release];
        [super dealloc];
}

#pragma mark Selection

-(void)selectNavigationItemAtIndex:(NSInteger)index
{
        if ([self numberOfItems] > 0) {
                if ([self isEnabled] == NO)
                        [self setEnabled:YES];
                
                if (index < 0 || index >= [self numberOfItems]) {
                        [self selectItem:nil];
                        if ([[self cell] menuItem] != noSelectionMenuItem)
                                [[self cell] setMenuItem:noSelectionMenuItem];
                } else {
                        [self selectItemAtIndex:index];
                        if ([[self cell] menuItem] != [self selectedItem])
                                [[self cell] setMenuItem:[self selectedItem]];
                }
        }
}

-(void)selectNavigationItemWithLineNumber:(NSUInteger)lineNumber
{
        NSArray * sortedRanges = nil;
        NSInteger selectionIndex = -1;
        
        sortedRanges = sortNavigationRanges([_dataSource rangesForNavigationPopUpButton:self]);
        for (NSValue * range in [sortedRanges reverseObjectEnumerator]) {
                if (NSLocationInRange(lineNumber, [range rangeValue])) {
                        selectionIndex = [self indexOfItemWithRepresentedObject:range];
                        break;
                }
        }
        [self selectNavigationItemAtIndex:selectionIndex];
}

-(void)selectNavigationItem:(NSMenuItem *)item
{
        [self selectNavigationItemAtIndex:[self indexOfItem:item]];
}

-(void)selectNavigationItemWithTitle:(NSString *)title
{
        if (title == nil)
                [self selectNavigationItemAtIndex:-1];
        else
                [self selectNavigationItemAtIndex:[self indexOfItemWithTitle:title]];
}

#pragma mark Menu Actions

/**
 * \brief Notify the delegate that a menu item was clicked.
 *
 * \details This is the action of all menu items in the menu. When called,
 *          send a navigationPopUpButton:didClickMenuItemWithRange: method to
 *          the delegate if it implements it.
 */
-(IBAction)clickMenuItem:(NSMenuItem *)sender
{
        if ([_delegate respondsToSelector:@selector(navigationPopUpButton:didClickMenuItemWithRange:)]) {
                [_delegate navigationPopUpButton:self
                       didClickMenuItemWithRange:[[[self selectedItem] representedObject] rangeValue]];
        }
}

/**
 * \brief Reload the menu before it is displayed.
 *
 * \details Prior to receiving a mouseDown event, reload all items in the
 *          navigation popup button menu.
 *
 * \param theEvent The mouse down event.
 */
-(void)mouseDown:(NSEvent *)theEvent
{
        [self reloadData];
        [super mouseDown:theEvent];
}

#pragma mark Menu items

-(void)reloadData
{
        __block NSMenuItem * menuItem = nil;
        __block NSImage * menuImage = nil;
        __block NSUInteger indentationLevel = 0;
        NSArray * ranges = nil, * sortedRanges = nil;
        NSString * selectedTitle = nil;
        CGFloat imageHeight = 14.0;
        
        /* Store selected title for restoration at method return.
         * Retain it to avoid issue if the item is removed from the menu below.
         */
        selectedTitle = [[self titleOfSelectedItem] retain];
        
        /* The removeAllItems method removes the cell, so clear it first if it
         * is the noSelectionMenuItem
         */
        if ([[self cell] menuItem] == noSelectionMenuItem)
                [[self cell] setMenuItem:nil];
        
        /* Update menu items */
        [self removeAllItems];
        ranges = [_dataSource rangesForNavigationPopUpButton:self];
        
        if ([ranges count] == 0) {
                if ([[self cell] menuItem] != noNavigationMenuItem)
                        [[self cell] setMenuItem:noNavigationMenuItem];
                [self selectItem:nil];
                [self setEnabled:NO];
        } else {
                sortedRanges = sortNavigationRanges(ranges);
                [sortedRanges enumerateObjectsUsingBlock:^(NSValue * obj, NSUInteger idx, BOOL *stop) {
                        menuItem = [[[NSMenuItem alloc] init] autorelease];
                        [menuItem setTitle:[_dataSource navigationPopUpButton:self titleForRange:[obj rangeValue]]];
                        [menuItem setRepresentedObject:obj];

                        /* Calculate indentation level */
                        indentationLevel = 0;
                        for (int i = 0; i < idx; i++) {
                                if (NSLocationInRange([obj rangeValue].location, [[sortedRanges objectAtIndex:i] rangeValue]))
                                        indentationLevel++;
                        }
                        [menuItem setIndentationLevel:indentationLevel];
                        
                        /* Get image */
                        if ([_dataSource respondsToSelector:@selector(navigationPopUpButton:imageForRange:)]) {
                                menuImage = [_dataSource navigationPopUpButton:self imageForRange:[obj rangeValue]];
                                [menuImage setSize:NSMakeSize(imageHeight, imageHeight)];
                                [menuItem setImage:menuImage];
                        }
                        
                        [[self menu] addItem:menuItem];
                }];
                [self selectNavigationItemWithTitle:selectedTitle];
        }
        [selectedTitle release];
}

@end
