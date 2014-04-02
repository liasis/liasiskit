/**
 * \file PLDocument.h
 * \brief Headerfile containing the public interface for the document base class.
 *
 * \details Interface file for the document base class and the protocol for 
 *          subclasses of the document base class.
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

#import <Foundation/Foundation.h>

@class PLDocument;

/**
 * \protocol PLDocumentSubclass \headerfile \headerfile
 *
 * \brief Defines the methods a document subclass must implements to be
 *        functional within the Liasis document framework.
 *
 * \details This protocol is meant to be suplement classes that inherit from 
 *          `PLDocument`. The `PLDocumentManager` assumes all document objects
 *          to inherit from `PLDocument` and that they implement the methods
 *          defined in this protocol. The methods defined in this protocol
 *          are important for document loading (through the `setData:` method);
 *          document saving (through the `documentData` method) and testing 
 *          if a document has unsaved changes (through the `isEqualToDocument:`
 *          method).
 *
 * \see PLDocument
 *
 */
@protocol PLDocumentSubclass <NSObject>

/**
 * \details Objects that conform to this protocol must implement this method
 *          to compare cached versions of the document with the document
 *          accesible to the user.
 * 
 * \param document A `PLDocument` subclass that conforms to the
 *                 `PLDocumentSubclass` protocol.
 *
 * \return A BOOL value that indicates if the argument document is equal to the
 *         receiver. If they are not equal, method returns NO.
 *
 * \note This method is not necessarily be commutative. This may arise from the 
 *       use of subclasses of PLDocument subclasses.
 *           
 *           PLDocument * A = [[PLTextDocument alloc] init];
 *           PLDocument * B = [[PLRichTextDocument alloc] init];
 *           // The following statement may not always be true:
 *           [A isEqualToDocument:B] == [B isEqualToDocument:A];
 *
 */
-(BOOL)isEqualToDocument:(PLDocument<PLDocumentSubclass> *)document;

/**
 * \details Objects that conform to this protocol must implement this method
 *          in order for the documents to reflect documents in files. The
 *          `setData:` method shifts the responsibility of file loading to 
 *          the `PLDocumentManager` and creates a simple interface for loading
 *          documents and updating document data. Furthermore, it enforces that
 *          document subclasses clearly define how raw data is decoded and used
 *          to construct a document model. If a nil data object is passed, it
 *          should be assumed that it should reflect an empty document.
 *
 * \param data A NSData object reflecting a stream of bytes, such as the data
 *             from a file or the data of another object.
 */
-(void)setData:(NSData *)data;

/**
 * \details Objects that conform to this protocol must implement this method
 *          in order for the `PLDocumentManager` to obtain a NSData representation
 *          of the contents of a document. The `documentData` method shifts the
 *          responsibility of file writing to the `PLDocumentManager`.
 *
 * \return An NSData instance encoded to with the contents of a document
 *         instance.
 */
-(NSData *)documentData;

@end

/**
 * \class PLDocument \headerfile \headerfile
 *
 * \brief A document base class that implements the necessary functionality to
 *        communicate with the `PLDocumentManager` and the PLTabViewController`.
 *
 * \details This class is meant to be inherited by concrete document classes. It
 *          defines the basic interface for the document manager and the tab
 *          view controller, and implements the generic functions related to
 *          allocation, file referencing, equality and document locking. All
 *          document classes must be a subclass of `PLDocument` in order to 
 *          function properly. `PLDocument` subclasses must implement three 
 *          additional methods to be viable: the `setData:` method; the
 *          `documentData` method; and the `isEqualToDocument:` method.
 *          In addition, they should provide some API for interacting with the
 *          document.
 *
 * \see PLDocumentSubclass
 *
 */
@interface PLDocument : NSObject <NSCopying> {
        @protected
        /**
         * \brief An NSData object used to keep track of files on the file
         *        system and to uniquely identify document objects.
         */
        NSData * bookmarkData;
        /**
         * \brief An NSLock object used to lock edits to a document that are
         *        within `beginEdit` and `endEdit` clauses.
         */
        NSLock * documentLock;
}

@property (readwrite, retain) NSUndoManager * documentUndoManager;

/**
 * \brief Factory method that creates a new empty document method.
 *
 * \details This method calls the `PLDocument::init` method on an instance of a 
 *           `PLDocument` subclass.
 *
 * \return id A new instance of the document class. If the document fails to
 *            initialize, this function returns nil.
 */
+(id)emptyDocument;

/**
 * \brief Factory method that creates a new document method from a fileURL.
 *
 * \details This method calls the `PLDocument::initWithContentsOfURL:error:`
 *          method on an instance of a `PLDocument` subclass.
 *
 * \param absoluteURL An NSURL object with the URL from which the document will
 *                    load its data.
 *
 * \param error A pointer of to an NSError object that will be used to store
 *              the value of any exceptions that may occur during file load.
 *
 * \return id A new instance of the document class. If the document fails to
 *            initialize, this function returns nil.
 */
+(id)documentWithContentsOfURL:(NSURL *)absoluteURL error:(NSError **)error;

#pragma mark - Document Initialization
/**
 * \brief Method to initialize a new document with the contents of a file at a
 *        given URL.
 *
 * \details This method calls initializes the `PLDocument` subclass by calling
 *          `init`. It then sets the bookmark data of the `PLDocument` by 
 *          sending a `PLDocument::setBookmarkData:` message. Finally, it sends
 *          the `PLDocument` subclass a `setData:` message, which must be
 *          implemented by a subclass of `PLDocument`. 
 *
 *
 * \param absoluteURL An NSURL object with the URL from which the document will
 *                    load its data.
 *
 * \param error A pointer of to an NSError object that will be used to store
 *              the value of any exceptions that may occur during file load.
 *
 * \return A new instance of the document class. If the document fails to
 *         initialize, this function returns nil.
 */
-(id)initWithContentsOfURL:(NSURL *)absoluteURL error:(NSError **)error;

/**
 * \brief Create a copy of the object.
 *
 * \details This method creates a deep copy of the object. PLDocument subclasses
 *          should not require modifications to this function. This function
 *          initializes a new insance of the PLDocument subclass and then 
 *          calls `setData:` using a copy of the current document's data.
 *          Therefore, subclasses of `PLDocument` that conform to the
 *          `PLDocumentSubclass` protocol should gain NSCopying functionality
 *          for free.
 *
 * \param zone An NSZone indicating the zone of memory from which the object
 *             will be allocated. If zone is NULL, the memory is allocated from
 *             the default zone, returned by the NSDefaultMallocZone method.
 *
 * \return An instance of a copy of the current document.
 */
-(id)copyWithZone:(NSZone *)zone;

#pragma mark Document Properties: Filename, fileURLs and bookmark data.

/**
 * \brief Method that returns the preferred name of the file.
 *
 * \details The default implementation of this method returns the last path
 *          component of the document. If the document is an empty document, 
 *          as in it does not represent a file on the file system, the it 
 *          requests the `PLDocumentManager` for its name.
 *
 * \return NSString An instance of NSString with the name of `PLDocument`
 *                  object.
 *
 *
 * \see PLDocumentManager::filenameForTemporaryDocument
 */
-(NSString *)filename;

/**
 * \brief Method that returns the file URL for the `PLDocument`object.
 *
 * \details This method returns the URL for the file represented by the document
 *          object. The file URL is obtained by converting the bookmark data
 *          that is used by the `PLDocument` object to track the associated file.
 *
 * \return NSString If the document is not empty, this method returns an NSURL
 *                  object pointing to the location of the file. Otherwise, 
 *                  return nil.
 *
 * \see PLDocumentManager::filenameForTemporaryDocument
 */
-(NSURL *)fileURL;

/**
 * \brief Method to set the bookmark data of the `PLDocument` object.
 *
 * \details The bookmark data is important in this document management system
 *          as it is used to uniquely identify documents associated to files
 *          on the file system. This bookmark data allows the application to 
 *          track movements of the file while Liasis is running. Documents
 *          pointing to the same URL may have different bookmark data, hence
 *          allowing for multiple `PLDocument` subclasses to be open that
 *          reference a single file.
 *
 * \param data An NSData object that has file system bookmark data.
 *
 * \see PLDocumentManager::bookmarkFromURL:
 * \see PLDocumentManager::URLFromBookmark:
 * \see PLDocument::bookmarkData
 */
-(void)setBookmarkData:(NSData *)data;

/**
 * \brief Method to get the bookmark data of the `PLDocument` object.
 *
 * \return NSData An NSData object that has file system bookmark data. If there
 *                is no bookmark data, hence it is a temporary document, it 
 *                returns nil.
 *
 * \see PLDocumentManager::bookmarkFromURL:
 * \see PLDocumentManager::URLFromBookmark:
 * \see PLDocument::bookmarkData
 */
-(NSData *)bookmarkData;


#pragma mark Utility methods

/**
 * \brief Method that locks the document prior to editing a document object.
 *
 * \details This method is intended to preceed all edits on a `PLDocument`
 *          subclass. The method locks the document, which is then unlocked when
 *          calling the `endEdit` message. Subclasses may override this method,
 *          however it is recommended that a call to `[super beginEdit]` edit be
 *          made before implementing a custom `beginEdit` method.
 *
 * \see PLDocument::endEdit
 */
-(void)beginEdit;

/**
 * \brief Method that unlocks the document following an edit operation on a
 *        a document object. This method triggers a
 *        `PLDocumentWasEditedNotification`.
 *
 * \details This method must be called after a `beginEdit` call on a `PLDocument`
 *          subclass. It is intended to be called after an edit operation. The
 *          method also triggers a notification, which is used by the document
 *          manager to determine if there was a change in the document's saved
 *          state.  Subclasses may override this methodd and similarly to the
 *          `beginEdit` method, it is recommended that a call to
 *          `[super endEdt]` edit be made after implementing a custom `endEdit`
 *          method.
 *
 * \see PLDocument::beginEdit
 * \see PLDocumentWasEditedNotification
 * \see PLDocument
 */
-(void)endEdit;

/**
 * \brief Method that is used to check if two instances of a document are equal.
 *
 * \details This method is implemented by the `PLDocument` base class. This
 *          implementation does routine checks such as identity checks and class
 *          consistency. It then invokes the `isEqualToDocument:` method defined
 *          in the `PLDocument` protocol. `PLDocument` subclasses must implement
 *          the `isEqualToDocument:` method, which is used heavily by the
 *          `PLDocumentManager` to ascertain if a change in the saved state of a
 *          document has occurred.
 *
 * \param object The object that will be checked for equality with the receiver.
 *
 * \return BOOL A BOOL value indicating if the object that received the message
 *              and the `object` argument are equal as defined by a `PLDocument`
 *              subclass.
 *
 * \see PLDocument
 */
-(BOOL)isEqual:(id)object;


@end
