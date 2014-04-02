/**
 * \file NSColor+hexToColor.m
 * \brief Liasis Python IDE extension of NSColor class implementation file.
 *
 * \details
 * This file contains the method for a simple extension to the NSColor object, 
 * providing the interface for a factory that creates an NSColor object from a
 * hexadecimal string representation.
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

#import "NSColor+hexToColor.h"

@implementation NSColor (hexToColor)


+(NSColor *)colorWithHexadecimalString:(NSString*)hexColorString
{
        NSColor* result = nil;
        unsigned colorCode = 0;
        unsigned char redByte, greenByte, blueByte;
        
        if (nil != hexColorString)
        {
                NSScanner* scanner = [NSScanner scannerWithString:hexColorString];
                (void) [scanner scanHexInt:&colorCode]; // ignore error
        }
        redByte = (unsigned char)(colorCode >> 16);
        greenByte = (unsigned char)(colorCode >> 8);
        blueByte = (unsigned char)(colorCode); // masks off high bits
        
        result = [NSColor
                  colorWithCalibratedRed:(CGFloat)redByte / 0xff
                  green:(CGFloat)greenByte / 0xff
                  blue:(CGFloat)blueByte / 0xff
                  alpha:1.0];
        return result;
}

+(NSColor *)colorWithInvertedRedGreenBlueComponents:(NSColor *)aColor
{
        id color = [self colorWithCalibratedRed:1.0f-[aColor redComponent]
                                          green:1.0f-[aColor greenComponent]
                                           blue:1.0f-[aColor blueComponent]
                                          alpha:[aColor alphaComponent]];
        return color;
}


@end
