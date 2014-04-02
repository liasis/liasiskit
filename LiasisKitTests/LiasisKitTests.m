/**
 * \file LiasisKitTests.m
 * \brief Unit tests for LiasisKit.
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
 * \author Jason Lomnitz.
 * \author Danny Nicklas.
 * \date 2012-2014.
 */

#import <XCTest/XCTest.h>
#import <LiasisKit/LiasisKit.h>

@interface LiasisKitTests : XCTestCase

@end

@implementation LiasisKitTests

/**
 * \brief Test the PLFormatter class.
 *
 * \details Test two class methods: retrieving indentation strings and
 *          determining matching brackets.
 *
 *          To test the indentationStringOfText:atIndex method:
 *              1) Check that line 1 has zero indentation (index 0)
 *              2) Check that line 2 has four indentation spaces (index 16)
 *              3) Check that line 6 has eight indentation spaces (index 90)
 *
 *          To test the characterIndexForNextOpenBracket:fromIndex method, test
 *          the following positions (in order of appearance):
 *              1) Before first list bracket (index 4)
 *              2) Inside tuple 1 (index 9)
 *              3) Before tuple 2 (index 13)
 *              4) Inside tuple 2 (index 23)
 *              5) Inside tuple 3 (index 28)
 *              6) End of tuple 3 (index 32)
 *              7) Between lists (at plus sign, index 34)
 *              8) Inside tuple 4 (index 39)
 *              9) End of tuple 4 (index 43)
 *              10) Outside of the string (index 44)
 */
-(void)testFormatter
{
        NSString * source;
        
        /* test indentation level */
        source = [NSString stringWithUTF8String:"def func(arg1):\n"
                  "    print arg1\n"
                  "    return arg1 * 2\n"
                  "\n"
                  "def func2():\n"
                  "    def inner():\n"
                  "        print 1\n"
                  "    x = inner\n"
                  "    return x\n"];
        XCTAssertEqualObjects(@"", [PLFormatter indentationStringOfText:source atIndex:0]);
        XCTAssertEqualObjects(@"    ", [PLFormatter indentationStringOfText:source atIndex:16]);
        XCTAssertEqualObjects(@"        ", [PLFormatter indentationStringOfText:source atIndex:90]);
        
        /* test bracket matching */
        source = [NSString stringWithUTF8String:"x = [(1, 2),\n"
                                                "     (3, 4), (5, 6)] + [(7, 8)]"];
        XCTAssertEqual([PLFormatter characterIndexForNextOpenBracket:source fromIndex:4], NSNotFound);
        XCTAssertEqual([PLFormatter characterIndexForNextOpenBracket:source fromIndex:9], (NSUInteger)5);
        XCTAssertEqual([PLFormatter characterIndexForNextOpenBracket:source fromIndex:13], (NSUInteger)4);
        XCTAssertEqual([PLFormatter characterIndexForNextOpenBracket:source fromIndex:23], (NSUInteger)18);
        XCTAssertEqual([PLFormatter characterIndexForNextOpenBracket:source fromIndex:28], (NSUInteger)26);
        XCTAssertEqual([PLFormatter characterIndexForNextOpenBracket:source fromIndex:32], (NSUInteger)4);
        XCTAssertEqual([PLFormatter characterIndexForNextOpenBracket:source fromIndex:34], NSNotFound);
        XCTAssertEqual([PLFormatter characterIndexForNextOpenBracket:source fromIndex:39], (NSUInteger)37);
        XCTAssertEqual([PLFormatter characterIndexForNextOpenBracket:source fromIndex:43], (NSUInteger)36);
        XCTAssertEqual([PLFormatter characterIndexForNextOpenBracket:source fromIndex:44], NSNotFound);
}

@end
