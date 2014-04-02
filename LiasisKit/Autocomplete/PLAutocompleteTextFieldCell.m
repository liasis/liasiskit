/**
 * \file PLAutocompleteTextFieldCell.m
 * \brief Liasis Python IDE autocomplete text field cell implementation file.
 *
 * \details This is a NSTextFieldCell subclass that provides support for
 *          drawing text with or without using screen font substitution.
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
 * along with Liasis. If not, see <http://www.gnu.org/licenses/>.
 *
 * \author Danny Nicklas.
 * \author Jason Lomnitz.
 * \date 2012-2014.
 *
 */

#import "PLAutocompleteTextFieldCell.h"

@implementation PLAutocompleteTextFieldCell

/**
 * \brief Initialize the text field cell.
 *
 * \details Set the usesScreenFonts property to NO.
 *
 * \return The initialized autocomplete text field cell.
 */
-(id)init
{
        self = [super init];
        if (self)
                _usesScreenFonts = NO;
        return self;
}

/**
 * \brief Subclass method to draw the text field cell.
 *
 * \details Draw the cell's attributed string using screen font substitution
 *          according to the usesScreenFonts property. Sets the x origin of the
 *          drawn rect to the table's intercellSpacing width.
 *
 *          Note: while [self titleRectForBounds:cellFrame] seems like the
 *          appropriate approach to determine the title rect, it did not
 *          transform the cellFrame. Therefore, the drawn frame is modified with
 *          the intercellSpacing.
 *
 * \param cellFrame The bounding rect, or a portion thereof, of the receiver.
 *
 * \param controlView The control that manages the cell.
 */
-(void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
        NSSize intercellSpacing = [(NSTableView *)controlView intercellSpacing];
        NSRect drawFrame = cellFrame;
        NSStringDrawingOptions drawOptions = NSStringDrawingUsesLineFragmentOrigin;
        
        if (_usesScreenFonts == NO)
                drawOptions |= NSStringDrawingDisableScreenFontSubstitution;
        drawFrame.origin.x = intercellSpacing.width;
        [[self attributedStringValue] drawWithRect:drawFrame
                                           options:drawOptions];
}

@end
