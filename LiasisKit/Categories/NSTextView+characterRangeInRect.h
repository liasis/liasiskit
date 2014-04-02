/**
 * \file NSTextView+characterRangeInRect.h
 * \brief Liasis Python IDE extension of NSColor class interface file.
 *
 * \details
 * This file contains the function prototypes and interface for a simple
 * extension to the NSTextView object, providing a method to get the range of
 * characters inside a designated rect.
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
 * along with Liasis. If not, see
 * <http://www.gnu.org/licenses/>.
 *
 * \author Danny Nicklas.
 * \author Jason Lomnitz.
 * \date 2012-2014.
 *
 */
#import <AppKit/AppKit.h>

/**
 * \extends NSTextView
 *
 * \brief An extension to the NSTextView object.
 *
 * \details This extension adds one instance method that provides the character
 *          range of a text view's NSRect.
 */
@interface NSTextView (characterRangeInRect)

/**
 * \brief Method to retrieve the character range of viewable characters within
 *        the bounds of the text view client.
 *
 * \details Method checks the visibleRect of the client text view and retrieves
 *          the character range for the bounding rectangle throught the layout
 *          manager.
 *
 * \return An NSRange with the range of characters displayed within the bounds
 *          of the client NSTextView.
 */
-(NSRange)characterRangeInRect:(NSRect)aRect;

@end
