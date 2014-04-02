/**
 * \file PLNavigationItem.h
 * \brief Liasis Python IDE navigation item.
 *
 * \details This file contains the interface for a navigation item. This is a
 *          container object that contains properties related to menu items in
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

#import <Foundation/Foundation.h>

/**
 * \class PLNavigationItem \headerfile \headerfile
 *
 * \brief A container object containing properties to simplify passing around
 *        navigation-related information.
 *
 * \details This container is closely related to the PLNavigationDataSource in
 *          that it contains the properties returned by its delegate methods,
 *          namely the title of a navigation item and its image. One example of
 *          its usage may be for an introspection controller object, which has a
 *          close relationship with source code to pass information to a data
 *          source.
 *
 * \see PLNavigationDataSource
 */
@interface PLNavigationItem : NSObject

/**
 * \brief The title of the navigation item.
 */
@property (retain) NSString * title;

/**
 * \brief The image of the navigation item.
 */
@property (retain) NSImage * image;

@end
