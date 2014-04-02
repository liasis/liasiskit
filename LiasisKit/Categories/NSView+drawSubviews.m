/**
 * \file NSView+drawSubviews.m
 * \brief Implementation file for an extension of the NSView class for
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

#import "NSView+drawSubviews.h"

@implementation NSView (drawSubviews)

- (void)drawSubviews
{
        BOOL flipped = [self isFlipped];
        for ( NSView *subview in [self subviews] ) {
                if ([subview isHidden]) {
                        continue;
                }
                NSAffineTransform *transform = [NSAffineTransform transform];
                if ( flipped ) {
                        [transform translateXBy:subview.frame.origin.x yBy:NSMaxY(subview.frame)];
                        [transform scaleXBy:+1.0 yBy:-1.0];
                } else
                        [transform translateXBy:subview.frame.origin.x yBy:subview.frame.origin.y];
                [transform concat];
                [subview drawRect:[subview bounds]];
                [subview drawSubviews];
                [transform invert];
                [transform concat];
        }
}

@end
