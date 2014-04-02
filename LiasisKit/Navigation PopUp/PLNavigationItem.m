/**
 * \file PLNavigationItem.m
 * \brief Liasis Python IDE navigation item.
 *
 * \details This file contains the implementation for a navigation item. This is
 *          a container object that contains properties related to menu items in
 *          a PLNavigationPopUpButton.
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
 */

#import "PLNavigationItem.h"

@implementation PLNavigationItem

-(void)dealloc
{
        [_title release];
        [_image release];
        [super dealloc];
}

@end
