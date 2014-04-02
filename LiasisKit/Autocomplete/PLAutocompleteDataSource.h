/**
 * \file PLAutocompleteDataSource.h
 * \brief Liasis Python IDE autocomplete table view data source interface file.
 *
 * \details This is the autocomplete table view's data source object, conforming
 *          to the NSTableViewDataSource protocol. It provides the list of
 *          possible autocomplete words.
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

#import <Foundation/Foundation.h>

/**
 * \class PLAutocompleteDataSource \headerfile \headerfile
 *
 * \brief Data source for the autocomplete table view, containing the suggested
 *        list of completions.
 */
@interface PLAutocompleteDataSource : NSObject <NSTableViewDataSource>

/**
 * \brief The array of completions.
 */
@property (retain) NSArray * completions;

@end
