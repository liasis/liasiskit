/**
 * \file PLScroller.h
 * \brief Interface file for the PLScroller class.
 *
 * \details The PLScroller defined by this interface file is used to generate
 *          a document minimap as the scroll view's scroller.
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

#import <AppKit/AppKit.h>
#import "NSTextView+characterRangeInRect.h"

FOUNDATION_EXPORT enum PL_SCROLLER_TYPE {
        PL_SCROLLER_DEFAULT = 0,
        PL_SCROLLER_CLASSIC,
        PL_SCROLLER_OVERLAY
} PLScrollerType;
/**
 * \class PLScroller \headerfile \headerfile
 *
 * \brief A subclass of NSScroller used to display a minimap of a scroll view's
 *        document view.
 *
 * \details The PLScroller class is compatible with a NSScrollView's vertical
 *          scroller and is used to display the minimap by scaling the document
 *          view in the scroll view knob rect. By scaling the document view
 *          within the PLScroller's frame, the PLScroller should be able to 
 *          work with any NSView subclass that is displayed as part of the
 *          scroll view.
 *
 * \todo Increase the knob's tracking area when used as overlay scrollers.
 */
@interface PLScroller : NSScroller {
        NSView * documentView;
}

/**
 * \brief Defines the view for which a minimap will be displayed in the knob slot.
 */
@property (retain) NSView *documentView;

#pragma mark - Customizing NSScroller behavior

/**
 * \brief Method to determine if the PLScroller class is compatible with an overlay
 *        display.
 *
 * \return This method returns YES for the PLScroller class. If the PLScroller
 *         is subclassed, the default will be NO.
 */
+(BOOL)isCompatibleWithOverlayScrollers;

/**
 * \brief Method to determine the scroller width of the PLScroller class.
 *
 * \param controlSize This parameter is not used, and can be any size.
 *
 * \param scrollerStyle This parameter is currently unused. This would indicate
 *                      if the scroller is overlay or legacy style. It may be
 *                      useful to adjust the width of the scroller depending on
 *                      the scroller style, as legacy scrollers occupy usable
 *                      space within the scroll view.
 *
 * \return A CGFloat value indicating the width, in points, of the PLScroller
 *         instance.
 *
 */
+(CGFloat)scrollerWidthForControlSize:(NSControlSize)controlSize scrollerStyle:(NSScrollerStyle)scrollerStyle;

+(void)setScrollerType:(enum PL_SCROLLER_TYPE)type;

/**
 * \brief Method to set the frame and recalculate the scaling factor.
 *
 * \param frameRect An NSRect defining the rectangle in which the scroller will
 *                  display the minimap.
 *
 * \see coordinateScalingFactor()
 */
-(void)setFrame:(NSRect)frameRect;

/**
 * \brief Method to obtain the appropriate rectangle for the different parts of the
 *        NSScroller.
 *
 * \details This method only calculates the rect for the knob and the knob slot.
 *          The knob slot rectangle is defined as the scrollers bounds rect, while
 *          the knob itself is calculated by retrieving the visible rect of the
 *          document view, and scaling it according to the factor obtained in the
 *          coordinateScalifFactor() function.
 *
 * \param partCode A value indicating the component of the NSScroller for which
 *                 its rectangle is being requested.
 *
 * \see coordinateScalingFactor()
 */
-(NSRect)rectForPart:(NSScrollerPart)partCode;

#pragma mark Drawing Methods

/**
 * \brief Method to begin the drawing process of the scroller.
 *
 * \details This method calls the drawKnobSlotInRect: method, followed by the drawKnob
 *          method. It is explicitly used to ensure that the knob slot and knob
 *          are explicitly drawn during the fade in and out that occurs with
 *          overlay scrollers.
 *
 * \param dirtyRect An NSRect indicating the rectangle - relative to view's
 *                  coordinate system - that needs to be drawn.
 *
 * \see coordinateScalingFactor()
 */
-(void)drawRect:(NSRect)dirtyRect;

/**
 * \brief Method to draw the knob slot, which is the document view's minimap.
 *
 * \details This method draws a scaled-down version of the document view, and
 *          achieves this by invoking the document views drawRect method with
 *          the rect that will be displayed in the minimap. The coordinates system
 *          for the document view are maintained but drawing is fitted to the 
 *          minimap's coordinate system by applying an affine transform that
 *          scales and translates them appropriately.
 *
 * \param slotRect An NSRect indicating the rectangle that will be used to draw
 *                 the minimap.
 *
 * \param flag A BOOL value indicating whether or not the minimap should be
 *             highlighted. This is currently unused when drawing the minimap.
 *
 */
-(void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)flag;

/**
 * \brief Method to draw the knob, which represents the document view's visible
 *        rect.
 *
 * \details This method draws a partially transparent square that represents
 *          the document view's visible rect. The rect that corresponds to
 *          the knob is obtained by calling the rectForPart: method.
 */
-(void)drawKnob;

@end
