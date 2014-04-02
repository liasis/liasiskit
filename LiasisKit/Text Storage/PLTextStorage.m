/**
 * \file PLTextStorage.m
 * \brief Liasis Python IDE custom text storage object implementation file.
 *
 * \details
 * This file contains the function implementation for a NSTextStorage
 * subclass to post notification before the text storage data is manipulated.
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
 * \author Danny Nicklas.
 * \author Jason Lomnitz.
 * \date 2012-2014.
 *
 */

#import "PLTextStorage.h"

NSString * PLTextStorageWillReplaceStringNotification = @"PLTextStorageWillReplaceString";
NSString * PLTextStorageDidReplaceStringNotification = @"PLTextStorageDidReplaceString";

@implementation PLTextStorage

- (id)initWithString:(NSString *)aString
{
	if (self = [super init])
	{
		_internalStorage = [[NSMutableAttributedString alloc] initWithString:aString];
	}
	return self;
}

- (id)initWithString:(NSString *)aString attributes:(NSDictionary *)attributes
{
	if (self = [super init])
	{
		_internalStorage = [[NSMutableAttributedString alloc] initWithString:aString attributes:attributes];
	}
	return self;
}


- (id)initWithAttributedString:(NSAttributedString *)attrStr {
        if (self = [super init]) {
                _internalStorage = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
        }
        return self;
}

-(id)init
{
        self = [super init];
        if (self) {
                _internalStorage = [[NSMutableAttributedString alloc] initWithString:@""];
        }
        return self;
}

-(void)dealloc
{
        [_internalStorage release];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [super dealloc];
}

#pragma mark - Replacement information

@synthesize replacementString;
@synthesize replacementRange;

#pragma mark - NSAttributedString and NSMutableAttributedString primitives (necessary)

-(NSUInteger)length
{
        return [_internalStorage length];
}

-(NSString *)string
{
        return [_internalStorage string];
}

-(NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
        return [_internalStorage attributesAtIndex:location effectiveRange:range];
}

-(void)replaceCharactersInRange:(NSRange)range withString:(NSString *)string
{
        NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];
        replacementString = [NSString stringWithString:string];
        replacementRange = range;
        [defaultCenter postNotificationName:PLTextStorageWillReplaceStringNotification
                                     object:self];
        [_internalStorage replaceCharactersInRange:range withString:string];
        NSUInteger deltaLength = [string length] - range.length;
        [super edited:NSTextStorageEditedCharacters
               range:range
      changeInLength:deltaLength];
        [defaultCenter postNotificationName:PLTextStorageDidReplaceStringNotification
                                     object:self];
        replacementRange = NSMakeRange(NSNotFound, 0);
        replacementString = nil;
        return;
}

-(void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
        [_internalStorage setAttributes:attrs range:range];
        [super edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (void)addAttribute:(NSString *)name value:(id)value range:(NSRange)aRange
{
	[_internalStorage addAttribute:name value:value range:aRange];
	[self edited:NSTextStorageEditedAttributes
               range:aRange
        changeInLength:0];
}

#pragma mark - New text storage functionality

-(void)replaceCharactersInRange:(NSRange)range withAttributedString:(NSAttributedString *)attrString
{
        NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];
        replacementString = [attrString string];
        replacementRange = range;
        [defaultCenter postNotificationName:PLTextStorageWillReplaceStringNotification
                                     object:self];
        [_internalStorage replaceCharactersInRange:range withAttributedString:attrString];
        NSUInteger deltaLength = [attrString length] - range.length;
        [super edited:NSTextStorageEditedCharacters|NSTextStorageEditedAttributes
                range:range
       changeInLength:deltaLength];
        [defaultCenter postNotificationName:PLTextStorageDidReplaceStringNotification
                                     object:self];
        replacementRange = NSMakeRange(NSNotFound, 0);
        replacementString = nil;
        return;
}

-(void)addAttributeWithoutEditing:(NSString *)name value:(id)value range:(NSRange)aRange
{
        [_internalStorage addAttribute:name value:value range:aRange];
}

-(void)addAttributesWithoutEditing:(NSDictionary *)attrs range:(NSRange)aRange
{
        [attrs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [self addAttributeWithoutEditing:key value:obj range:aRange];
        }];
}

@end
