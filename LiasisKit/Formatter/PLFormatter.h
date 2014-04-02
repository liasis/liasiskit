/**
 * \file PLFormatting.h
 * \brief Liasis Python IDE text formatting manager.
 *
 * \details
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

/**
 * \class PLFormatter \headerfile \headerfile
 * \brief Provide automatic indentation and tab cycling features for the Liasis
 *        Text Editor view extension.
 *
 * \details This class controls automatic indentation to match open iterables
 *          and function/class definitions. It also provides support for cycling
 *          indentation backwards and jumping forward to the proper indentation
 *          level.
 */
@interface PLFormatter : NSObject
{
        /**
         * \brief The previously entered text by the user, used for tab cycling.
         */
        NSString * previousEntry;
        
        /**
         * \brief The location of the previously entered text by the user, used
         *        for tab cycling (determining where a previous tab was
         *        entered).
         */
        NSUInteger previousEntryLocation;
}

@property (retain) NSString * previousEntry;
@property NSUInteger previousEntryLocation;

/**
 * \brief Apply automatic indentation to the text view.
 *
 * \details If the user enters a newline character, determine the indentation
 *          level of the next line (depending on if the current line is indented
 *          or if inside an open bracket). If the user enters a tab character,
 *          perform tab cycling by first moving the insertion point to the
 *          correct indentation level and then cycling backwards.
 *
 * \param textView The NSTextView to format.
 *
 * \param replacementString The string that was entered by the user into the
 *                          text view.
 *
 * \param affectedRange The range of the replacement string.
 *
 * \return A boolean specifying if formatting was performed.
 */
-(BOOL)didFormatTextView:(NSTextView *)textView withReplacementString:(NSString *)replacementString inRange:(NSRange)affectedRange;

/**
 * \brief Return a string of whitespace equal in length to the proper
 *        indentation level at the particular index.
 *
 * \param text The text document to parse for proper indentation level.
 *
 * \param index The index in the text document where the indentaiton level is
 *              determined.
 *
 * \return A string of whitespace equal in length to the proper indentation
 *         level.
 */
+(NSString *)indentationStringOfText:(NSString *)text atIndex:(NSUInteger)index;

/**
 * \brief Function to find the innermost opening bracket.
 *
 * \details Function searches the previous line(s) for the innermost openning
 *          bracket that does not have its corresponding closing bracket.
 *
 * \param text An instance of a NSString object that contains the text
 *             of the python document.
 *
 * \param startingCharacter The index of a character in the line for
 *                          which the proper indentation is being
 *                          identified.
 *
 * \return NSUInteger If a opening bracket was found without it's corresponding
 *                    closing bracket, returns the index of the opening bracket.
 *                    Otherwise, returns NSNotFound.
 */
+(NSUInteger)characterIndexForNextOpenBracket:(NSString *)text fromIndex:(NSUInteger)startingCharacter;

/**
 * \brief Toggle the selected text to be commented out or removed comment block.
 *
 * \details This function inserts traditional comments and block comments before
 *          each line in a single column. The two comment varieties are defined
 *          as follows:
 *
 *              Block:       Uses the string "## " to comment out a block. These
 *                           are added to a line independent of its current
 *                           content. As such, they will be added even if a
 *                           section of code already has these comment strings.
 *              Traditional: Uses the string "# " to comment out lines of code.
 *                           These are only added to lines that don't have this
 *                           already. This introduces a possible issue when
 *                           commenting out lines of code that are meant to be
 *                           title comments (already prefaced with the comment
 *                           string) because they will be toggled off. But it
 *                           allows for smarter commenting by adding to
 *                           previously commented lines rather than introducing
 *                           a new level of comments as the Block comments will.
 *
 *          This function first determines the minimum indentation level of all
 *          selected lines, ignoring those that contain only whitespace. It then
 *          determines if the line is commented out at the minimum indentation
 *          level. Depending on the status of the lines and the type of comments
 *          used, comment strings are added selectively, added to the entire
 *          selection, or removed from the entire selection.
 *
 *          The selected text is largely unchanged. This function attempts to
 *          maintain the same selected text before and after the commenting or
 *          uncommenting procedure.
 *
 * \param textView A NSTextView to insert or remove commenting. This is modified
 *                 in place.
 *
 * \param commentBlock If YES, use the Block comment style. Otherwise, use the
 *                     traditional comment style.
 */
+(void)toggleCommentSelection:(NSTextView *)textView asBlock:(BOOL)commentBlock;

/**
 * \brief Increase the indentation level of a selection.
 *
 * \details Function iterates over each line in a selection and increases the
 *          indentation level of all. The selection is maintained after the
 *          indentation increase with the following details:
 *              If selection begins at start of line, increase the selection
 *                  length, but maintain its location.
 *              If selection begins in whitespace region, clip to start of line:
 *                  If selection length is entirely in whitespace, remove the
 *                      selection.
 *                  If selection length spans whitespace and text, remove the
 *                      selection in whitespace.
 *              Otherwise, shift the selection location with the indentation.
 *
 * \param textView The NSTextView to increase the indentation level and modify
 *                 the resulting selection.
 */
+(void)increaseIndentationInSelection:(NSTextView *)textView;

/**
 * \brief Decrease the indentation level of a selection.
 *
 * \details Function iterates over each line in a selection and decreases the
 *          indentation level of all. If the indentation level is less than the
 *          traditional indentation level (4 spaces for Python), it is shifted
 *          to the start of the line. The selection is maintained after the
 *          indentation decrease with the following details:
 *              If selection begins at start of line, decrease the selection
 *                  length, but maintain its location.
 *              If selection begins in whitespace region, clip to start of line:
 *                  If selection length is entirely in whitespace, remove the
 *                      selection.
 *                  If selection length spans whitespace and text, remove the
 *                      selection in whitespace.
 *              Otherwise, shift the selection location with the indentation.
 *
 * \param textView The NSTextView to decrease the indentation level and modify
 *                 the resulting selection.
 */
+(void)decreaseIndentationInSelection:(NSTextView *)textView;


@end
