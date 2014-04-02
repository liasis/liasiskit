/**
 * \file PLTextDocument.m
 * \brief Implementation file for the text document class.
 *
 * \copyright
 *
 * Copyright (C) 2012-2013 Danny Nicklas and Jason Lomnitz.\n\n
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
 * \date 2013
 *
 */

#import "PLTextDocument.h"
#import "PLDocumentManager.h"

@implementation PLTextDocument

#pragma mark - Document Initialization

-(void)dealloc
{
        [currentString release];
        [super dealloc];
}

-(void)setData:(NSData *)data
{
        [self beginEdit];
        [currentString release];
        if ([data length] != 0)
                currentString = [[NSMutableString alloc] initWithData:data
                                                             encoding:NSUTF8StringEncoding];
        else
                currentString = [[NSMutableString alloc] initWithString:@""];
        [self endEdit];
}

-(NSData *)documentData
{
        NSData * data = [currentString dataUsingEncoding:NSUTF8StringEncoding];
        return data;
}


-(NSString *)currentString
{
        return [NSString stringWithString:currentString];
}

-(BOOL)isEqualToDocument:(PLDocument<PLDocumentSubclass> *)aDocument
{
        BOOL areEqual = NO;
        NSString * documentString;
        if (aDocument == nil) {
                goto exit;
        }
        if ([aDocument isKindOfClass:[self class]] == NO) {
                goto exit;
        }
        documentString = [(PLTextDocument*)aDocument currentString];
        if ([documentString isEqual:currentString]) {
                areEqual = YES;
        }
exit:
        return areEqual;
}

#pragma mark Modifying a document

-(BOOL)editCharactersInRange:(NSRange)aRange withString:(NSString *)aString
{
        BOOL didEdit = NO;
        [self beginEdit];
        if (currentString == nil) {
                goto exit;
        }
        if (NSIntersectionRange(NSMakeRange(0, [currentString length]),
                                aRange).location != NSNotFound) {
                didEdit = YES;
                [currentString replaceCharactersInRange:aRange withString:aString];
        }
exit:
        [self endEdit];
        return didEdit;
}

@end
