/**
 * \file PLAutocompleteTableView.m
 * \brief Liasis Python IDE autocomplete table view implementation file.
 *
 * \details This is a NSTableView subclass that provides gradient highlighting
 *          for its rows and posts a notification when a user clicks on a row.
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
 */

#import "PLAutocompleteTableView.h"

@implementation PLAutocompleteTableView

@dynamic delegate;

/**
 * \brief Subclassed method for highlighting selections in the table view.
 *
 * \details This method highlights the rect of the selected item in the table
 *          view. It uses the selection gradient returned from the theme
 *          manager.
 */
-(void)highlightSelectionInClipRect:(NSRect)clipRect;
{
        NSInteger selectedRowIndex = [self selectedRow];
        if (selectedRowIndex < 0)
                return;
        NSGradient * gradient = [[PLThemeManager defaultThemeManager] selectionGradient];
        [gradient drawInRect:[self rectOfRow:selectedRowIndex] angle:90];
}

/**
 * \brief Subclassed method for receiving mouseDown events.
 *
 * \details This method first determines the row clicked through the rowAtPoint:
 *          method. If the row is valid (i.e. not negative), send its delegate
 *          the tableView:shouldReceiveMouseDownInRow: message. If the delagate
 *          returns YES, call the superclass mouseDown: method.
 *
 * \param theEvent The event resulting from the user action.
 */
-(void)mouseDown:(NSEvent *)theEvent
{
        NSPoint pointInSelf = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        NSInteger selectedRow = [self rowAtPoint:pointInSelf];
        if (selectedRow < 0 || [[self delegate] tableView:self shouldReceiveMouseDownInRow:selectedRow])
                [super mouseDown:theEvent];
}

@end
