//
//  NSTextView+characterRangeInRect.m
//  Liasis
//
//  Created by Jason Lomnitz on 8/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NSTextView+characterRangeInRect.h"

@implementation NSTextView (characterRangeInRect)

-(NSRange)characterRangeInRect:(NSRect)aRect
{
        NSLayoutManager *layoutManager;
        NSTextContainer *textContainer;
        NSRange glyphRange, characterRange;
        NSPoint textContainerOrigin;
        textContainer = [self textContainer];
        layoutManager = [self layoutManager];
        textContainerOrigin = [self textContainerOrigin];
        aRect.origin.x -= textContainerOrigin.x;
        aRect.origin.y -= textContainerOrigin.y;
        glyphRange = [layoutManager glyphRangeForBoundingRect:aRect
                                              inTextContainer:textContainer];
        characterRange = [layoutManager characterRangeForGlyphRange:glyphRange
                                                   actualGlyphRange:nil];
        return characterRange;
}

@end
