/**
 * \file PLDocumentManager.m
 * \brief Implementation file for the document manager class.
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

#import "PLDocumentManager.h"
#import "PLTextDocument.h"
#import "PLAddOnManager.h"

NSString * const PLDocumentWasEditedNotification = @"PLDocumentWasEdited";
NSString * const PLDocumentWasSavedNotification = @"PLDocumentWasSaved";
NSString * const PLDocumentSavedStateChangedNotification = @"PLDocumentSavedStateChanged";

@implementation PLDocumentContainer



@end

@implementation PLDocumentManager

+(id)sharedDocumentManager
{
        static id documentManager;
        if (documentManager == nil) {
                documentManager = [[self alloc] init];
                // ... initialize event stream...
        }
        return documentManager;
}

#pragma mark Initialization

-(id)init
{
        NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];
        self = [super init];
        if (self) {
                documents = [[NSMutableDictionary alloc] init];
                temporaryDocuments = [[NSMutableArray alloc] init];
                [defaultCenter addObserver:self
                                  selector:@selector(appDidBecomeActive:)
                                      name:NSApplicationDidBecomeActiveNotification
                                    object:[NSApplication sharedApplication]];
        }
        return self;
}


-(void)dealloc
{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [documents release];
        [temporaryDocuments release];
        [super dealloc];
}

#pragma mark Accessing and adding managed documents.

-(id)documentForURL:(NSURL *)loadURL
{
        id document = nil;
        NSData * bookmarkData = nil;
        if (loadURL == nil) {
                goto exit;
        }
        bookmarkData = [self bookmarkFromURL:loadURL];
        document = [self documentForBookmark:bookmarkData];
exit:
        return document;
}

-(id)documentForBookmark:(NSData *)bookmarkData
{
        PLDocument<PLDocumentSubclass> * document = nil, *cached;
        PLAddOnManager * addOnManager = [PLAddOnManager defaultManager];
        PLDocumentContainer * container;
        NSURL * loadURL = nil;
        NSBundle * defaultBundle;
        NSString * fileType;
        loadURL = [self urlFromBookmark:bookmarkData];
        container = [documents objectForKey:bookmarkData];
        fileType = [loadURL pathExtension];
        defaultBundle = [addOnManager defaultAddOnForFileType:fileType];
        cached = [[addOnManager documentClassForAddOn:defaultBundle] documentWithContentsOfURL:loadURL
                                                                                         error:nil];
        if (container != nil) {
                document = container.userDocument;
                goto exit;
        }
        document = [[addOnManager documentClassForAddOn:defaultBundle] documentWithContentsOfURL:loadURL
                                                                                           error:nil];
        if (document != nil) {
                container = [PLDocumentContainer new];
                container.userDocument = document;
                container.cached = cached;
                container.saved = YES;
                [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:loadURL];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(documentWasEdited:)
                                                             name:PLDocumentWasEditedNotification
                                                           object:document];
                [documents setObject:container forKey:bookmarkData];
                [container release];
        }
exit:
        return document;
}

#pragma mark Save document

-(id)saveDocument:(id)document
{
        NSURL * saveURL = [self urlFromBookmark:[document bookmarkData]];
        document = [self saveDocument:document atURL:saveURL];
exit:
        return document;
}

-(id)saveDocument:(id)document atURL:(NSURL *)saveURL
{
        NSWorkspace * workspace = [NSWorkspace sharedWorkspace];
        NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];
        NSError * error = nil;
        if ([(NSData *)[document documentData] writeToURL:saveURL atomically:YES] == NO) {
                NSLog(@"Error writing to file");
                error = nil;
                goto exit;
        }
        if ([saveURL isEqualTo:[document fileURL]] == YES) {
                goto exit;
        }
        document = [self documentForURL:saveURL];
exit:
        [self updateCachedDocument:document];
        [defaultCenter postNotificationName:PLDocumentWasSavedNotification
                                     object:document];
        [workspace noteFileSystemChanged:[saveURL path]];
        return document;
}

-(id)saveDocumentPanel:(PLDocument<PLDocumentSubclass> *)document
{
        return [self saveDocumentPanel:document
                        withExtensions:@[[[document filename] pathExtension]]];
}

-(id)saveDocumentPanel:(PLDocument<PLDocumentSubclass> *)document
        withExtensions:(NSArray *)extensions
{
        NSSavePanel * savePanel = [[NSSavePanel savePanel] retain];
        NSURL * fileURL;
        PLDocument<PLDocumentSubclass> * newDocument = nil;
        [savePanel setAllowedFileTypes:extensions];
        [savePanel setAllowsOtherFileTypes:YES];
        [savePanel setCanCreateDirectories:YES];
        if ([document bookmarkData]) {
                fileURL = [self urlFromBookmark:[document bookmarkData]];
                [savePanel setDirectoryURL:[fileURL URLByDeletingLastPathComponent]];
                [savePanel setNameFieldStringValue:[fileURL lastPathComponent]];
        }
        if ([savePanel runModal] == NSFileHandlingPanelOKButton) {
                fileURL = [savePanel URL];
                newDocument = [self saveDocument:document atURL:fileURL];
        }
        [savePanel release];
        return newDocument;
}

#pragma mark Temporary documents

-(id)addTemporaryDocument:(NSString *)extension
{
        id document = nil;
        PLAddOnManager * addOnManager = [PLAddOnManager defaultManager];
        for (NSBundle * addOn in [addOnManager extensionBundles]) {
                if ([[addOnManager allowedFileTypesForAddOn:addOn] containsObject:extension]) {
                        document = [[addOnManager documentClassForAddOn:addOn] emptyDocument];
                        [temporaryDocuments addObject:document];
                        break;
                }
                
        }
exit:
        return document;
}

-(NSString *)filenameForTemporaryDocument:(id)document
{
        NSString * filename = nil;
        filename = [NSString stringWithFormat:@"Untitled %li", [temporaryDocuments indexOfObject:document]+1];
        return filename;
}

#pragma mark Document state verification

-(BOOL)documentIsOpen:(NSURL *)fileURL
{
        BOOL isOpen = NO;
        id document = nil;
        NSData * bookmarkData = nil;

        if (fileURL == nil) {
                goto exit;
        }
        bookmarkData = [self bookmarkFromURL:fileURL];
        document = [[documents objectForKey:bookmarkData] userDocument];
        if (document != nil) {
                isOpen = YES;
        }

exit:
        return isOpen;
}

-(void)documentWasEdited:(NSNotification *)notification
{
        PLDocument<PLDocumentSubclass> * document, *cached;
        PLDocumentContainer * container;
        BOOL isSaved;
        document = [notification object];
        container = [documents objectForKey:[document bookmarkData]];
        if (container == nil)
                goto exit;
        cached = container.cached;
        isSaved = [document isEqualToDocument:cached];
        if (isSaved != container.saved) {
                container.saved = isSaved;
                [[NSNotificationCenter defaultCenter] postNotificationName:PLDocumentSavedStateChangedNotification
                                                                    object:document];
        }
exit:
        return;
}

-(BOOL)documentIsEditable:(NSURL *)fileURL
{
        NSFileManager * fileManager = [NSFileManager defaultManager];
        BOOL isEditable = YES;
        fileURL = [fileURL fileReferenceURL];
        if (fileURL == nil)
                goto exit;
        isEditable = [fileManager isWritableFileAtPath:[fileURL path]];
exit:
        return isEditable;
}

-(BOOL)documentIsEdited:(PLDocument<PLDocumentSubclass> *)document
{
        BOOL edited = YES;
        NSData * bookmarkData = [document bookmarkData];
        if (bookmarkData == nil) {
                goto exit;
        }
        edited = ![[documents objectForKey:bookmarkData] saved];
exit:
        return edited;
}

#pragma mark Bookmark data and URL conversion

- (NSData *)bookmarkFromURL:(NSURL *)url {
        NSData *bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationMinimalBookmark
                         includingResourceValuesForKeys:NULL
                                          relativeToURL:NULL
                                                  error:NULL];
        return bookmark;
}

- (NSURL *)urlFromBookmark:(NSData *)bookmark {
        NSURL *url = [NSURL URLByResolvingBookmarkData:bookmark
                                               options:NSURLBookmarkResolutionWithoutUI
                                         relativeToURL:NULL
                                   bookmarkDataIsStale:NO
                                                 error:NULL];
        return url;
}

#pragma mark - Private -

/**
 * \brief Method to check if the state of a document has been changed 
 *        externally.
 *
 * \details This method is used to update the internal representation of all
 *          saved documents when the application regains an active state.
 *          It checks to see if the cahced instance of all managed documents are 
 *          still accurate when compared with what is stored on disk. If there
 *          are inconsistencies, it updates the cached version of the managed
 *          documents.
 *
 * \param aNotification The `NSNotification` that is sent when the app becomes 
 *                      active.
 */
-(void)appDidBecomeActive:(NSNotification *)aNotification
{
        NSFileManager * fileManager =[NSFileManager defaultManager];
        PLDocument<PLDocumentSubclass> *saved, *cached, * document;
        PLDocumentContainer * container;
        NSString * alert;
        NSInteger closeStatus;
        NSURL * fileURL;
        for (NSData * i in [documents allKeys]) {
                container = [documents objectForKey:i];
                document = container.userDocument;
                cached = container.cached;
                fileURL = [self urlFromBookmark:i];
                if ([fileManager isReadableFileAtPath:[fileURL path]] == NO) {
                        NSLog(@"File is no longer readable at path");
                        continue;
                }
                saved = [[cached class] documentWithContentsOfURL:fileURL
                                                            error:nil];
                if ([saved isKindOfClass:[cached class]] == NO) {
                        continue;
                }
                if ([cached isEqualToDocument:saved])
                        continue;
                [cached retain];
                [self updateCachedDocument:document];
                if ([cached isEqualToDocument:document]) {
                        [document setData:[saved documentData]];
                } else {
                        alert = [NSString stringWithFormat:
                                 @"The document \"%@\" has been changed by another application and has unsaved changes.",
                                 [document filename]];
                        closeStatus = NSRunCriticalAlertPanel(@"File Changed", alert, @"Save As...", @"Do Nothing", @"Discard Changes", nil);
                        switch (closeStatus) {
                                case NSAlertDefaultReturn:
                                        saved = [self saveDocumentPanel:document];
                                        [[NSApp delegate] application:NSApp openFile:[[saved fileURL] path]];
                                        container.saved = YES;
                                        [document setData:[container.cached documentData]];
                                        break;
                                case NSAlertAlternateReturn:
                                        container.saved = NO;
                                        break;
                                case NSAlertOtherReturn:
                                        container.saved = YES;
                                        [document setData:[container.cached documentData]];
                                        break;
                                default:
                                        break;
                        }
                }
                [cached release];
        }
exit:
        return;
}

/**
 * \brief Method to update a documents cached instance.
 *
 * \details This method is used to update the internal representation of the 
 *          saved document. This is necessary in case a file represented by a
 *          managed document has changed by an external application. This
 *          method is used to keep the state of the document consistent
 *          with the state of the represented data on disk and to resolve
 *          conflicts when there are inconsistencies.
 *
 * \param userDocument The user `PLDocument` for which its cached pair will be
 *                     updated.
 */
-(void)updateCachedDocument:(PLDocument<PLDocumentSubclass> *)userDocument
{
        PLDocument<PLDocumentSubclass> *cached;
        PLAddOnManager * addOnManager = [PLAddOnManager defaultManager];
        PLDocumentContainer * container;
        NSData * bookmarkData;
        NSURL * loadURL = nil;
        NSBundle * defaultBundle;
        NSString * fileType;
        bookmarkData = [userDocument bookmarkData];
        container = [documents objectForKey:bookmarkData];
        if (container == nil) {
                goto exit;
        }
        loadURL = [self urlFromBookmark:bookmarkData];
        fileType = [loadURL pathExtension];
        defaultBundle = [addOnManager defaultAddOnForFileType:fileType];
        cached = [[addOnManager documentClassForAddOn:defaultBundle] documentWithContentsOfURL:loadURL
                                                                                         error:nil];
        container.cached = cached;
        [[NSNotificationCenter defaultCenter] postNotificationName:PLDocumentWasEditedNotification
                                                            object:userDocument];
exit:
        return;
}

@end
