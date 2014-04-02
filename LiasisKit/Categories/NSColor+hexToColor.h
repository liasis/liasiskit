/**
 * \file NSColor+hexToColor.h
 * \brief Liasis Python IDE extension of NSColor class interface file.
 *
 * \details
 * This file contains the function prototypes and interface for a simple
 * extension to the NSColor object, providing the interface for a factory
 * that creates an NSColor object from a hexadecimal string representation.
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
 * \extends NSColor
 *
 * \brief An extension to the NSColor object.
 *
 * \details This extension adds two factory methods that facilitate NSColor
 *          creation from a hexadecimal string, and creation of an inverted
 *          color from a color in the RGB colorspace.
 */
@interface NSColor (hexToColor)

/**
 * \brief Factory method for the NSColor class, creates a NSColor from a
 *        hexadecimal string.
 *
 * \details This method adds support for NSColor creation from a hexadecimal
 *          format, used primarily with the theme manager. The algorithm used
 *          follows the recipe from :
 *          <http://stackoverflow.com/questions/8697205/convert-hex-color-code-to-nscolor>
 *
 * \param hexColorString A NSString object containing a color in hexadecimal
 *                       representation.
 *
 * \return An NSColor object on the autorelease pool.
 */
+(NSColor *)colorWithHexadecimalString:(NSString*)hexColorString;

/**
 * \brief Factory method for the NSColor class, creates a NSColor from the
 *        inversion of another NSColor.
 *
 * \details This method inverts the RGB components of an NSColor.
 *
 * \param aColor The NSColor to invert.
 *
 * \return An NSColor object on the autorelease pool.
 */
+(NSColor *)colorWithInvertedRedGreenBlueComponents:(NSColor *)aColor;

@end
