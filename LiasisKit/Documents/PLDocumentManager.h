/**
 * \file PLDocumentManager.h
 * \brief Headerfile containing the public interface for the document manager class.
 *
 * \details Interface file for the add on manager class, responsible for
 *          opening files and making them accesible to the application.
 *          The document manager is in charge of detecting if changes to the
 *          documents it manages have occurred.
 *
 * \copyright
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
 * \date 2013
 *
 */
#import <Foundation/Foundation.h>
#import "PLDocument.h"

/**
 * \brief Notification posted by the `PLDocument` base class after an `endEdit`
 *        call.
 *
 * \details The `PLDocumentManager` observes this notification and checks for 
 *          changes in the saved state of the document. If the saved state has 
 *          changed, it posts a `PLDocumentSavedSateChangedNotification`.
 */
FOUNDATION_EXPORT NSString * const PLDocumentWasEditedNotification;

/**
 * \brief Notification posted by the `PLDocumentManager` after a PLDocument
 *        has been saved by the PLDocumentManager's `saveDocument:atURL:` method
 *        call.
 */
FOUNDATION_EXPORT NSString * const PLDocumentWasSavedNotification;

/**
 * \brief Notification posted by the `PLDocumentManager` after a PLDocument has
 *        been edited and the PLDocumentManager has detected in the saved state 
 *        the managed document.
 */
FOUNDATION_EXPORT NSString * const PLDocumentSavedStateChangedNotification;

@interface PLDocumentContainer : NSObject

@property(readwrite, retain, nonatomic) PLDocument<PLDocumentSubclass> * userDocument, * cached;
@property(readwrite, assign) BOOL saved;

@end


/**
 * \class PLDocumentManager \headerfile \headerfile
 *
 * \brief A class used to manage creatinig new documents, opening documents and
 *        saving documents.
 *
 * \details The class maintains a cache of open documents in their user and
 *          loaded state. Upon receiving notifications of edits from the
 *          documents it compares these two versions of the documents to
 *          determine if there has been a change in that document's saved state.
 *          This class also manages temporary documets that do not correspond
 *           to a file on the file system. The document manager keeps track of
 *          document URLs using bookmark data. The bookmark data uniquely
 *          identifies all the open documents. Temporary documents are stored
 *          using a simple NSArray.  When opening files, instances of this class
 *          check with the add-on manager to determine which document types are
 *          supported by the current add-ons in the PlugIns folder. It does this
 *          by loading specific entries in their plist files.
 */
@interface PLDocumentManager : NSObject {
    /**
     * \brief Dictionary of open document.
     *
     * \details The dictionary of open documents uses the bookmark data for
     *          the document as the unique identifying key.
     */
    NSMutableDictionary * documents;
    /**
     * \brief Array of temporary document.
     *
     * \details The array of temporary documents is used to create new documents
     *          without associated files in the filesystem. Hence, there is no
     *          bookmark data available. Temporary documents are uniquely
     *          identified by their position within the temporaryDocument
     *          array.
     */
    NSMutableArray * temporaryDocuments;
}

/**
 * \brief Factory method that returns the instance of the application's shared
 *        document manager.
 *
 * \details This method returns a singleton that is designed to be application
 *          wide. It is used to manage all the documents loaded from the file
 *          browser, which includes all documents open in the tabs. This class
 *          can be used without the shared document manager.
 *
 * \return The singleton instance of the PLDocumentManager class.
 *
 * \note  The singleton is initialized using the standard
 *        `[[PLDocumentManager alloc] init];` calls and hence use of the
 *        shared document manager should only be used for application wide
 *        documents. Individual view extensions might want to manage documents
 *        seperately, and could create new `PLDocumentManager` instances.
 */
+(id)sharedDocumentManager;

#pragma mark Accessing and adding managed documents.

/**
 * \brief A convenience method that returns the document for a particular URL by
 *        by retrieving the bookmark data for that URL.
 *
 * \param loadURL A NSURL with the reference to the file for which a document
 *                is being requested.
 *
 * \return A PLDocument subclass with the contents of the URL. If the URL is nil,
 *         or the document could not be opened, it returns nil.
 *
 * \see PLDocumentManager::documentForURL:
 */
-(id)documentForURL:(NSURL *)loadURL;

/**
 * \brief Method that returns the document for a bookmark data obtained from a
 *        file URL.
 *
 * \param bookmark The bookmark data that is used to track the file URL that
 *                 contains the data on disk for the document of interest.
 *
 * \details This method attempts to retrieve a cached document for a particular
 *          bookmark. If no documents exist for that bookmark, then a new
 *          document is created by loading the contents in NSData format.
 *          The appropriate document class for the file is determined by
 *          consulting the PLAddOnManager. Once the appropriate document class
 *          is determined, it creates two new instance of that class by calling
 *          the `documentWithContentsOfURL:error:` factory method. One copy is to keep a
 *          record of the saved state of the document, while the second is to
 *          keep a record of edits by the user.
 *
 * \return A PLDocument subclass with the contents of the URL. If the URL is nil,
 *         or the document could not be opened, it returns nil.
 */
-(id)documentForBookmark:(NSData *)bookmark;

#pragma mark Save document


/**
 * \brief A convenience method that saves the document at its original location
 *        by retrieving its URL from its bookmark data.
 *
 * \details This method is equivalent to the following,
 *              [[PLDocumentManager sharedDocumentManager] saveDocument:document atURL:[document fileURL]];
 *
 *
 *
 * \param document A `PLDocument` subclass that conforms to the
 *                 `PLDocumentSubclass` protocol that will be saved.
 *
 * \return A PLDocument subclass with the same reference as the document that was
 *         saved.
 *
 * \see PLDocumentManager::saveDocument:atURL:
 */
-(id)saveDocument:(id)document;

/**
 * \brief Method that writes a document's data to a location specified by a
 *        URL.
 *
 * \details This method is used to write a document's contents to file. The data
 *          is obtained by calling the document's `documentData` method, which
 *          is then written to disk atomically using `NSData` method for writing
 *          to URL: it uses the `writeToUrl:atomically:`, passing the URL and
 *          setting `atomically:YES`.
 *
 * \param document A `PLDocument` subclass that will be saved. Document must
 *                 conforms to the `PLDocumentSubclass` protocol.
 *
 * \param saveURL The URL that will be used to save the `PLDocument` subclass's
 *                data.
 *
 * \return A PLDocument subclass with the reference as the document that was
 *         saved.
 *
 */
-(id)saveDocument:(id)document atURL:(NSURL *)saveURL;

/**
 * \brief Method to run a save panel for a existing document and sets the
 *        allowed extensions to that of the sent document's extension.
 *
 * \details Calling this method is equal to calling the 
 *          `saveDocumentPanel:withExtensions:` method, with the extensions
 *          being the path extension of the current document.
 *
 * \param document A `PLDocument` subclass that will be saved. Document must
 *                 conforms to the `PLDocumentSubclass` protocol.
 *
 * \return A PLDocument subclass with the reference as the document that was
 *         saved.
 *
 * \see PLDocumentManager::saveDocumentPanel:withExtensions:
 *
 */
-(id)saveDocumentPanel:(PLDocument<PLDocumentSubclass> *)document;

/**
 * \brief Method to open a savePanel for a existing document.
 *
 * \details This method is used to run a save panel that allows saved files
 *          to have specified extensions.
 *
 * \param document A `PLDocument` subclass that will be saved. Document must
 *                 conforms to the `PLDocumentSubclass` protocol.
 *
 * \return A PLDocument subclass with the reference as the document that was
 *         saved.
 *
 */
-(id)saveDocumentPanel:(PLDocument<PLDocumentSubclass> *)document
        withExtensions:(NSArray *)extensions;

#pragma mark Temporary documents

/**
 * \brief Method to add a new temporary document with a particular extension.
 *
 * \details This method is similar to the `documentForBookmark:` method except
 *          that the document has no associated file on disk. Thus creating a
 *          new document involves the same steps as in the former method,
 *          except that the new document isn't initialized with the
 *          `documentWithContentsOfURL:error:` factory method. Instead, it
 *          is initialized by the `emptyDocument` factory method.
 *
 * \param extension An NSString with the path extension indicating the type of
 *                  document that will be made.
 *
 * \return A PLDocument subclass with empty contents. If the extension is not
 *         recognized, returns nil.
 *
 * \see PLDocumentManager::documentForBookmark:
 */
-(id)addTemporaryDocument:(NSString *)extension;

/**
 * \brief Method to return the filename for a temporary document (filename for
 *        documents is defined by the bookmark data, which is non-existant for
 *        temporary documents).
 *
 * \param document A PLDocument subclass representing a temporary document.
 *
 * \return A NSString with the name of the temporary document. If the document
 *         is not a temporary document, returns nil.
 *
 */
-(NSString *)filenameForTemporaryDocument:(id)document;

#pragma mark Document state verification

/**
 * \brief Method to determine if a document has been opened by the document
 *        manager.
 *
 * \param fileURL A NSURL with the reference to the file that is being checked.
 *
 * \return A BOOL value with YES if the document has been opened. Otherwise,
 *         returns NO.
 */
-(BOOL)documentIsOpen:(NSURL *)fileURL;

/**
 * \brief Method to determine if a document is accesible with read-write
 *        permissions.
 *
 * \param fileURL A NSURL with the reference to the file that is being checked.
 *
 * \return A BOOL value with YES if the document can be written to. Otherwise,
 *         returns NO.
 */
-(BOOL)documentIsEditable:(NSURL *)fileURL;

/**
 * \brief Method to determine if a document has unsaved changes.
 *
 * \details This method determines the unsaved state differently for temporary
 *          and documents with data on disk. Temporary documents are always
 *          assumed to be unsaved. Open documents are determined unsaved by
 *          comparing the user version of the document with the cached version.
 *          It does so by calling the `isEqualToDocument:` method on the user
 *          version with the cached document as an argument. If this method
 *          returns NO, it is assumed the document has unsaved changes.
 *
 * \param document A PLDocument subclass to determine if it has unsaved changes.
 *
 * \return A BOOL with YES of the document has unsaved changes. Otherwise,
 *         returns NO.
 *
 */
-(BOOL)documentIsEdited:(PLDocument<PLDocumentSubclass> *)document;

#pragma mark Bookmark data and URL conversion

/**
 * \brief Convenience method for converting a URL to bookmark data.
 *
 * \param url A `NSURL` object specifying a location on disk for which 
 *            bookmark data is being requested.
 *
 * \return An instance of `NSData` with the bookmark data for the given URL.
 *         If bookmark data could not be gathered, returns nil.
 *
 * \see PLDocumentManager::urlFromBookmark:
 */
- (NSData *)bookmarkFromURL:(NSURL *)url;

/**
 * \brief Convenience method for converting bookmark data to a URL.
 *
 * \param bookmark An `NSData` object containing bookmark data used to track
 *                 files on the file system.
 *
 * \return An instance of `NSURL` corresponding to the current location of the
 *         file indicated by the bookmark data. If the bookmark data is invalid,
 *         the method returns nil.
 *
 * \see PLDocumentManager::urlFromBookmark:
 */
- (NSURL *)urlFromBookmark:(NSData *)bookmark;

@end
