/**
 * \file PLDocument.m
 * \brief Implementation file for the document base class.
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

#import "LiasisKit.h"
#import "PLDocument.h"
#import "PLDocumentManager.h"

@implementation PLDocument

#pragma mark Factory methods

+(id)emptyDocument
{
        id document = [[self alloc] init];
        return document;
}

+(id)documentWithContentsOfURL:(NSURL *)absoluteURL error:(NSError **)error
{
        id document = [(PLDocument *)[self alloc] initWithContentsOfURL:absoluteURL error:error];
        return [document autorelease];
}

#pragma mark Memory allocation, deallocation and object initialization.

-(id)init
{
        self = [super init];
        if (self) {
                bookmarkData = nil;
                self.documentUndoManager = [[[NSUndoManager alloc] init] autorelease];
                [self.documentUndoManager setLevelsOfUndo:100];
                // Sets data to nil. A nil data represents an empty document.
                [(PLDocument<PLDocumentSubclass> *)self setData:nil];

        }
        return self;
}

-(id)initWithContentsOfURL:(NSURL *)absoluteURL error:(NSError **)error
{
        self = [self init];
        PLDocumentManager * documentManager = [PLDocumentManager sharedDocumentManager];
        NSData * fileData = nil;
        if (self != nil) {
                bookmarkData = [[documentManager bookmarkFromURL:absoluteURL] retain];
                fileData = [NSData dataWithContentsOfURL:absoluteURL];
                if ([self respondsToSelector:@selector(setData:)]) {
                        [self performSelector:@selector(setData:) withObject:fileData];
                }
        }
        return self;
}

-(void)dealloc
{
        [bookmarkData release];
        [documentLock release];
        self.documentUndoManager = nil;
        [super dealloc];
}

#pragma mark Conforming to the NSCopying protocol. 

-(id)copyWithZone:(NSZone *)zone
{
        PLDocument * copy = [[[self class] allocWithZone:zone] init];
        [(PLDocument<PLDocumentSubclass> *)copy setData:[[(PLDocument<PLDocumentSubclass> *)self documentData] copyWithZone:zone]];
        return copy;
}

#pragma mark Document Properties: Filename, fileURLs and bookmark data.

-(NSString *)filename
{
        NSString * filename = nil;
        NSURL * fileURL;
        PLDocumentManager * documentManager = [PLDocumentManager sharedDocumentManager];
        fileURL = [documentManager urlFromBookmark:[self bookmarkData]];
        if (fileURL == nil) {
                filename = [[PLDocumentManager sharedDocumentManager] filenameForTemporaryDocument:self];
                goto exit;
        }
        filename = [fileURL lastPathComponent];
exit:
        return filename;
}

-(NSURL *)fileURL
{
        NSURL * fileURL;
        PLDocumentManager * documentManager = [PLDocumentManager sharedDocumentManager];
        fileURL = [documentManager urlFromBookmark:[self bookmarkData]];
        return fileURL;
}

-(void)setBookmarkData:(NSData *)data
{
        [data retain];
        [bookmarkData release];
        bookmarkData = data;
}

-(NSData *)bookmarkData
{
        return bookmarkData;
}

#pragma mark Utility methods

 -(void)beginEdit
{
        [documentLock lock];
}

-(void)endEdit
{
        [documentLock unlock];
        [[NSNotificationCenter defaultCenter] postNotificationName:PLDocumentWasEditedNotification object:self];
}

- (BOOL)isEqual:(id)object {
        BOOL areEqual = NO;
        PLDocument<PLDocumentSubclass> * document = object;
        if (self == object) {
                areEqual = YES;
                goto exit;
        }
        if (![object isKindOfClass:[self class]]) {
                goto exit;
        }
        if ([[[self fileURL] path] isEqualToString:[[document fileURL] path]] == NO) {
                goto exit;
        }
        areEqual = [(PLDocument<PLDocumentSubclass> *)self isEqualToDocument:document];
exit:
        return areEqual;
}


@end
