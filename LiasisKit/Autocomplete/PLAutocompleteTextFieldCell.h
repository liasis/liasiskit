/**
 * \file PLAutocompleteTextFieldCell.h
 * \brief Liasis Python IDE autocomplete text field cell interface file.
 *
 * \details This is a NSTextFieldCell subclass that provides support for
 *          drawing text with or without using screen font substitution.
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

#import <Cocoa/Cocoa.h>

/**
 * \class PLAutocompleteTextFieldCell \headerfile \headerfile
 *
 * \brief Subclass of NSTextFieldCell to provide support for screen font
 *        substitution handling.
 *
 * \details This class provides a usesScreenFonts property that determines if
 *          the attributed string inside the text field cell is drawn using
 *          screen fonts or not.
 */
@interface PLAutocompleteTextFieldCell : NSTextFieldCell

/**
 * \brief Boolean flag to use screen font substitution or not.
 */
@property(assign) BOOL usesScreenFonts;

@end
