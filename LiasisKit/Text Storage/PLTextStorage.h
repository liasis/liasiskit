/**
 * \file PLTextStorage.h
 * \brief Liasis Python IDE custom text storage object interface file.
 *
 * \details
 * This file contains the function prototypes and interface for a NSTextStorage
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

#import <Cocoa/Cocoa.h>
#import "PLTextDocument.h"


/**
 * \brief String notification used by objects to observe notifications posted
 *        by the PLTextStorage.
 * \details The PLTextStorage class posts a notification with the name contained
 *          by this variable during the replaceCharactersInRange:withString:
 *          method, prior to manipulating the text storage data. This notification
 *          is important for the line number view behavior, since it allows for
 *          calculating the differences between previous and novel states. 
 * \note This may also be used to determine if any changes have been made to a
 *       file from the last save point.
 *
 */
FOUNDATION_EXPORT NSString * PLTextStorageWillReplaceStringNotification;
FOUNDATION_EXPORT NSString * PLTextStorageDidReplaceStringNotification;

/**
 * \class PLTextStorage \headerfile \headerfile
 *
 * \brief A custom text storage object that adds specific functionality to the
 *        NSTextStorage class.
 *
 * \details This class allows the program to determine the difference between 
 *          the state of the text storage prior to editing, and the new state 
 *          following edits. This is important for the line number view, as
 *          the line number view calculates the line numbers by comparing the
 *          state of the text storage prior to performing edits to the data and
 *          the replacement text data. Additionally, this class allows editing 
 *          the text storage data without invoking the edited:range: method
 *          that can cause the text view to shift when altering text outside the
 *          scope of the visible rect.
 */
@interface PLTextStorage : NSTextStorage {
        /**
         * \brief An NSMutableAttributedString that serves as the actual data
         *        container.
         */
        NSMutableAttributedString * _internalStorage;
        NSString * replacementString;
        NSRange replacementRange;
}

#pragma mark - Replacement information

/**
 * \brief The replacement string that be used to alter the text storage
 *        data.
 *
 * \details This NSString instance is NULL for the majority of the time,
 *          and is non-NULL between the time the PLTextStorageWillReplaceStringNotification
 *          notification is posted to the default notification center,
 *          and the time the replacement takes effect.
 */
@property (readonly) NSString * replacementString;

/**
 * \brief The range of characters that will be replaced after the
 *        replaceCharactersInRange:withString: method has taken effect.
 *
 * \details The NSRange location is NSNotFound for the majority of the time,
 *          and is different only between the time the PLTextStorageWillReplaceStringNotification
 *          notification is posted to the default notification center,
 *          and the time the replacement takes effect.
 */
@property (readonly) NSRange replacementRange;

#pragma mark - NSAttributedString and NSMutableAttributedString primitives (necessary)

/**
 * \brief Method to replace the characters in the text storage object with a specific
 *        string.
 *
 * \details This function is a superclass method that has been edited to allow
 *          objects to determine the previous and new state of the text storage
 *          before the edits have taken effect. This is heavily used by the line 
 *          number view.
 *
 * \param range An NSRange specifying the range of characters in the text storage
 *              that will be replaced by a new string.
 *
 * \param string A string that contains the characters that will be inserted at
 *               the location specified by the range parameter, and replace the
 *               number of characters equal to the length of the range parameter
 */
-(void)replaceCharactersInRange:(NSRange)range withString:(NSString *)string;

/**
 * \brief Method to change an attribute for a range of characters without 
 *        setting an edited state in the text storage object.
 *
 * \param name An NSString containing the key for the attributes dictionary specifying
 *             the attribute that will be modified.
 *
 * \param value The new value for the given parameter that is being modified.
 *
 * \param aRange An NSRange indicating the range of characters for which the attribute 
 *               is being modified.
 */
-(void)addAttributeWithoutEditing:(NSString *)name value:(id)value range:(NSRange)aRange;

/**
 * \brief Method to change the attributes for a range of characters without
 *        setting an edited state in the text storage object.
 *
 * \param attrs The dictionary of attributes to add.
 *
 * \param aRange An NSRange indicating the range of characters for which the attribute
 *               is being modified.
 */
-(void)addAttributesWithoutEditing:(NSDictionary *)attrs range:(NSRange)aRange;

@end
