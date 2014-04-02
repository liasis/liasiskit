/**
 * \file PLTextDocument.h
 * \brief Headerfile containing the public interface for the text document class.
 *
 * \details Interface file for the add on manager class, in charge of loading and
 *          administering loaded add ons.
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
 * \date 2012-2014.
 *
 */

#import <Foundation/Foundation.h>
#import "PLDocument.h"

/**
 * \class PLTextDocument \headerfile \headerfile
 *
 * \brief A `PLDocument` subclass that represents text and conforms to the
 *        `PLDocumentSubclass` protocol.
 *
 * \details This class represents text documents from data. The current
 *          implementation assumes that the data is in UTF-8 format. The
 *          class maps this data with an NSMutableString object. This class is a
 *          simple extension of the base class: it adds a string instance 
 *          variable; adds a method that should be used to edit the document;
 *          and adds a method to retrieve the string represented by the
 *          document. It is the basic document that is used with the 
 *          Liasis Text Editor view extension.
 *
 * \see PLDocument
 */
@interface PLTextDocument : PLDocument <PLDocumentSubclass> {
        @private
        NSMutableString * currentString;
}

#pragma mark Modifying a document

/**
 * \brief Method to safely edit the state of the document.
 *
 * \param aRange An NSRange indicating the range of characters in the text that
 *               will be edited.
 *
 * \param aString The string that will replace the characters in the specified
 *                range of the text represneted by the document.
 *
 * \return Returns A BOOL variable with YES if the state of the document was
 *         succesfully modified. Otherwise, method returns NO.
 */
-(BOOL)editCharactersInRange:(NSRange)aRange withString:(NSString *)aString;

#pragma mark Check Document state

/**
 * \brief Method that returns the string represented by the document object.
 *
 * \return An NSString instance with the contents of the document. This should 
 *         never return nil.
 */
-(NSString *)currentString;


@end
