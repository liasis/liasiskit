/**
 * \file NSString+wordAtIndex.m
 * \brief Liasis Python IDE extension of NSString class implementation file.
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

#import "NSString+wordAtIndex.h"

@implementation NSString (wordAtIndex)

-(NSRange)wordRangeAtIndex:(NSUInteger)index
{        
        NSRange wordRange;
        NSUInteger previousAnchor = index, nextAnchor = index;
        NSMutableCharacterSet * characterSet = nil;

        characterSet = [NSMutableCharacterSet lowercaseLetterCharacterSet];
        [characterSet formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
        [characterSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
        [characterSet addCharactersInString:@"_"];

        /* Handle edge cases */
        if ([self length] == 0 ||
            (index == [self length] && [characterSet characterIsMember:[self characterAtIndex:index-1]] == NO)) {
                wordRange = NSMakeRange(0, 0);
                goto exit;
        }
        
        /* Find anchor points */
        while (previousAnchor > 0) {
                if ([characterSet characterIsMember:[self characterAtIndex:previousAnchor-1]] == NO)
                        break;
                previousAnchor--;
        }
        while (nextAnchor < [self length]) {
                if ([characterSet characterIsMember:[self characterAtIndex:nextAnchor]] == NO)
                        break;
                nextAnchor++;
        }
        wordRange = NSMakeRange(previousAnchor, nextAnchor - previousAnchor);
        
exit:
        return wordRange;
}

-(NSString *)wordAtIndex:(NSUInteger)index
{
        return [self substringWithRange:[self wordRangeAtIndex:index]];
}

@end
