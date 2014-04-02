/**
 * \file PLThemeable
 * \brief Liasis Python IDE themeable protocol file.
 *
 * \details This protocol file specifies all the methods that must be
 *          implemented by classes that are themeable, i.e. utilize a theme
 *          manager.
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

#import <Foundation/Foundation.h>
#import "PLThemeManager.h"

/**
 * \protocol A themeable object.
 *
 * \details This protocol specifies the method that a class must implement in
 *          order to be themeable. 'Themeable' specifies that the class will use
 *          the application's theme manager in defining its visible properties.
 */
@protocol PLThemeable <NSObject>

/**
 * \brief Update the object's theme manager using the application's default
 *        theme manager.
 */
-(void)updateThemeManager;

@optional

/**
 * \brief Update the object's font to a new font.
 */
-(void)updateFont:(NSFont *)font;


@end
