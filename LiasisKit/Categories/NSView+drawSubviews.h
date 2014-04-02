/**
 * \file NSView+drawSubviews.h
 * \brief Interface file for an extension of the NSView class for
 *        that adds a subview drawing method.
 *
 * \details This file contains the interface for an extension to the NSString
 *          object, which provides two instance methods to retrieve the word in
 *          the string at a given index.
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
 * \date 2012-2013
 *
 */

#import <Cocoa/Cocoa.h>

@interface NSView (drawSubviews)

/**
 * \brief Method that recursively draws subviews by traversing the
 *        subview hierarchy.
 *
 * \details This method draws a view's subviews recursively, by calling this 
 *          method on the subview and its subviews. In this way all subviews
 *          are drawn. Subviews that are hidden are ignored.
 */
- (void)drawSubviews;

@end
