/**
 * \file NSString+wordAtIndex.h
 * \brief Liasis Python IDE extension of NSString class interface file.
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

#import <Foundation/Foundation.h>

@interface NSString (wordAtIndex)

/**
 * \brief Return the range of a word at an index.
 *
 * \details Words are defined to be made up of characters in [a-zA-Z0-9_]. This
 *          method finds the bounding characters not in that set around an
 *          index. Return the empty range {0, 0} if the index is not in a word.
 *
 * \param string The string to search in.
 *
 * \param index The index in the string.
 *
 * \return The range of a word in a string.
 */
-(NSRange)wordRangeAtIndex:(NSUInteger)index;

/**
 * \brief Return the word at an index.
 *
 * \details This is a convenience method to call substringWithRange: using the
 *          result of wordRangeAtIndex:.
 *
 * \param string The string to search in.
 *
 * \param index The index in the string.
 *
 * \return The word at an index.
 *
 * \see wordRangeAtIndex:
 */
-(NSString *)wordAtIndex:(NSUInteger)index;

@end
