/**
 * \file PLScroller.m
 * \brief Implementation file for the PLScroller class.
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

#import "PLScroller.h"
#import "NSView+drawSubviews.h"

enum PL_SCROLLER_TYPE PLScrollerType;

#pragma mark Utility Functions (Prototypes)

/**
 * \brief Utility function to obtain the scaling factor between the actual
 *        document view and the version of the document view displayed in the
 *        minimap.
 *
 * \details This function determines the scaling factor by dividing the width of
 *          the minimap by the width of the document view. This scaling factor
 *          is used to scale both the width and height of the document view when
 *          drawing it within the bounds of the scroller.
 *
 * \param bounds An NSRect data structure containing the bounding rectangle for
 *               drawing inside the PLScroller knob.
 *
 * \param viewBounds An NSRect data structure containing the bounding rectangle
 *                   for the complete document view.
 *
 * \return A CGFloat value with the scaling factor that must be used to scale the
 *         height and width to properly display the document view within the
 *         scroller's frame.
 */
CGFloat coordinateScalingFactor(NSRect bounds, NSRect viewBounds);

#pragma mark Utility Functions (Implementation)

CGFloat coordinateScalingFactor(NSRect bounds, NSRect viewBounds) {
        CGFloat proportion = 0.0f;

        if (viewBounds.size.width > 0)
                proportion = bounds.size.width/viewBounds.size.width;
        return proportion;
}

@implementation PLScroller

@synthesize documentView;

-(id)initWithFrame:(NSRect)frameRect
{
        self = [super initWithFrame:frameRect];
        if (self) {
                documentView = nil;
        }
        
        return self;
}

-(void)dealloc
{
        [documentView release];
        [super dealloc];
}

#pragma mark - Customizing NSScroller behavior

+(BOOL)isCompatibleWithOverlayScrollers
{
        BOOL isCompatible = (self == [PLScroller class]);
        if (PLScrollerType == PL_SCROLLER_CLASSIC)
                isCompatible = NO;
        else if (PLScrollerType == PL_SCROLLER_OVERLAY)
                isCompatible = YES;
        return isCompatible;
}

+(NSScrollerStyle)preferredScrollerStyle
{
        NSScrollerStyle style = [super preferredScrollerStyle];
        switch (PLScrollerType) {
                case PL_SCROLLER_DEFAULT:
                        style = [super preferredScrollerStyle];
                        break;
                case PL_SCROLLER_CLASSIC:
                        style = NSScrollerStyleLegacy;
                        break;
                case PL_SCROLLER_OVERLAY:
                        style = NSScrollerStyleOverlay;
                        break;
                default:
                        break;
        }
        return style;
}

+(void)setScrollerType:(enum PL_SCROLLER_TYPE)type
{
        PLScrollerType = type;
}

-(NSScrollerStyle)scrollerStyle
{
        return [[self class] preferredScrollerStyle];
}

+(CGFloat)scrollerWidthForControlSize:(NSControlSize)controlSize scrollerStyle:(NSScrollerStyle)scrollerStyle
{
        return 120.0f;
}

-(void)setFrame:(NSRect)frameRect
{
        [super setFrame:frameRect];
        coordinateScalingFactor([self bounds], [documentView bounds]);
exit:
        return;
}


-(NSRect)rectForPart:(NSScrollerPart)partCode
{
        NSRect rect = NSZeroRect;
        NSAffineTransform * transform;
        NSPoint newOrigin = [self calculateViewOrigin];
        CGFloat proportion = coordinateScalingFactor([self bounds], [documentView bounds]);
        switch (partCode) {
                case NSScrollerKnob:
                        transform = [NSAffineTransform transform];
                        [transform scaleBy:proportion];
                        [transform translateXBy:0.0f yBy:newOrigin.y];
                        rect = [documentView visibleRect];
                        rect.origin = [transform transformPoint:rect.origin];
                        rect.size = [transform transformSize:rect.size];
                        break;
                case NSScrollerKnobSlot:
                        rect = [self bounds];
                        break;
                default:
                        break;
        }
        return rect;
}

-(void)drawRect:(NSRect)dirtyRect
{
        NSGraphicsContext * gc = [NSGraphicsContext currentContext];
        NSBezierPath * path;
        
        [gc saveGraphicsState];
        [[NSColor blackColor] setStroke];
        path = [NSBezierPath bezierPath];
        [path moveToPoint:[self bounds].origin];
        [path lineToPoint:NSMakePoint([self bounds].origin.x, [self bounds].origin.y+[self bounds].size.height)];
        [self drawKnobSlotInRect:[self bounds] highlight:NO];
        [self drawKnob];
        [path stroke];
        [gc restoreGraphicsState];
        return;
}

-(void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)flag
{
        NSPoint newOrigin;
        NSGraphicsContext * gc = [NSGraphicsContext currentContext];
        NSRect documentToDraw;
        CGFloat proportion = coordinateScalingFactor([self bounds], [documentView bounds]);
        documentToDraw = [documentView bounds];
        [gc saveGraphicsState];
        newOrigin = [self calculateViewOrigin];
        documentToDraw.origin = newOrigin;
        documentToDraw.origin.x += slotRect.origin.x;
        documentToDraw.origin.y += slotRect.origin.y;
        documentToDraw.size.height = slotRect.size.height/proportion;
        documentToDraw.origin.y *= -1;
        NSAffineTransform * transform = [NSAffineTransform transform];
        [transform scaleBy:proportion];
        [transform translateXBy:0.0f yBy:newOrigin.y];
        [transform concat];
        [documentView drawRect:NSIntegralRect(documentToDraw)];
        [documentView drawSubviews];
        [gc restoreGraphicsState];
        [gc saveGraphicsState];
        [gc restoreGraphicsState];
}

-(void)drawKnob
{
        NSRect knobPosition = [self rectForPart:NSScrollerKnob];
        NSGraphicsContext * gc = [NSGraphicsContext currentContext];
        [gc saveGraphicsState];
        [[NSColor colorWithCalibratedRed:0.3f
                                   green:0.3f
                                    blue:0.3f
                                   alpha:0.5f] set];
        [[NSBezierPath bezierPathWithRect:knobPosition] fill];
        [gc restoreGraphicsState];
}

-(CGFloat)knobProportion
{
        return 1.0;
}

-(void)trackKnob:(NSEvent *)theEvent
{
        NSRect bounds = [self bounds];
        NSRect documentRect = [documentView bounds];
        NSRect knob = [self rectForPart:NSScrollerKnob];
        NSSize proportionSize;
        CGFloat deltaY, newY;
        NSPoint scrollPoint;
        NSAffineTransform * transform;
        CGFloat proportion = coordinateScalingFactor([self bounds], [documentView bounds]);
        transform = [NSAffineTransform transform];
        [transform scaleBy:proportion];
        proportionSize = [transform transformSize:[documentView bounds].size];
        newY = knob.origin.y/(bounds.size.height-knob.size.height);
        while ([theEvent type] != NSLeftMouseUp) {
                theEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
                deltaY = [theEvent deltaY];
                newY += deltaY/(bounds.size.height-knob.size.height);
                newY = MIN(newY, (bounds.size.height-knob.size.height));
                newY = MAX(newY, 0.0f);
                if (proportionSize.height < bounds.size.height) {
                        scrollPoint = NSMakePoint([documentView visibleRect].origin.x,
                                                  (bounds.size.height-knob.size.height)*(newY/proportion));
                } else {
                        scrollPoint = NSMakePoint([documentView visibleRect].origin.x,
                                     (documentRect.size.height-[documentView visibleRect].size.height)*(newY));
                }
                [documentView scrollPoint:scrollPoint];
                [self setNeedsDisplay:YES];
        }
        [self sendAction:[self action] to:[self target]];
}

#pragma mark - Private Methods

/**
 * \brief Method to calculate what the document view's drawing rects origin
 *        will be to allow for scrolling of the knob slot.
 *
 * \details This method calculates the view origin by finding the percent of the
 *          document view that is able to be drawn in the scroller coordinates.
 *          And it adjusts the view origins such that the scroller knob moves
 *          smoothly from top to bottom.
 *
 * \return An NSPoint object with the appropriate origin that should be used
 *         when drawing the knob slot, and is also used for translating the
 *         origin of the knob itself.
 */
-(NSPoint)calculateViewOrigin
{
        NSRect knobRect = [super rectForPart:NSScrollerKnob];
        NSRect frame = [self bounds];
        NSPoint origin = NSZeroPoint;
        CGFloat proportion = coordinateScalingFactor([self bounds], [documentView bounds]);
        if ([self bounds].size.height/proportion < [documentView bounds].size.height) {
                origin.y = (knobRect.origin.y-frame.origin.y)/(frame.size.height-knobRect.size.height-2);
                origin.y *= -([documentView frame].size.height-frame.size.height/proportion);
        }
        return origin;
}

-(BOOL)isOpaque
{
        BOOL isOpaque = YES;
        NSScrollerStyle preferedStyle = [PLScroller preferredScrollerStyle];
        if (preferedStyle == NSScrollerStyleLegacy)
                isOpaque = YES;
        else
                isOpaque = NO;
        return isOpaque;
}


@end
