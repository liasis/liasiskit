/**
 * \file PLAutocompleteTextView.m
 * \brief Liasis Python IDE autocomplete text view implementation file.
 *
 * \details This is a NSTextView subclass that provides posts a notification
 *          when a user clicks inside.
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

#import "PLAutocompleteTextView.h"

@implementation PLAutocompleteTextView

@dynamic delegate;

/**
 * \brief Subclassed method for receiving mouseDown events.
 *
 * \details This method sends its delegate the textViewShouldReceiveMouseDown:
 *          message and calls the superclass mouseDown: method if the delegate
 *          returns YES.
 *
 * \param theEvent The event resulting from the user action.
 */
-(void)mouseDown:(NSEvent *)theEvent
{
        if ([[self delegate] textViewShouldReceiveMouseDown:self])
                [super mouseDown:theEvent];
}

@end
