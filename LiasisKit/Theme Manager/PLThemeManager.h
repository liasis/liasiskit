/**
 * \file PLThemeManager.h
 * \brief Liasis Python IDE theme manager implementation file.
 *
 * \details
 * This file contains the function prototypes and interface for the text editor
 * theme manager.
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
 * along with Liasis. If not, see
 * <http://www.gnu.org/licenses/>.
 *
 * \author Danny Nicklas.
 * \author Jason Lomnitz.
 * \date 2012-2014.
 *
 */

#import <Foundation/Foundation.h>
#import "NSColor+hexToColor.h"

/**
 * \class PLThemeManager \headerfile \headerfile
 * \brief Read/process theme files and expose their properties.
 *
 * \details The PLThemeManager controls reading, processing, and providing theme
 *          properties to the other Liasis objects. These currently include
 *          font colors and background colors for the document. Additionally,
 *          properties of the theme are grouped by the type of text they apply
 *          to. For example, language-specific keywords can be assigned a
 *          distinct font color from numbers.
 *
 *          Themes are specified as plist files and read by the PLThemeManager.
 *          This class also provides constants for accessing properties (e.g.
 *          font color) of groups (e.g. language-specific keywords).
 *
 * \todo Provide a standard implementation of theme files.
 */

/**
 * \brief The notification posted when the theme manager changes.
 */
FOUNDATION_EXPORT NSString * const PLThemeManagerDidChange;

/**
 * \details The default theme.
 */
FOUNDATION_EXPORT NSString * const PLThemeManagerDefaultTheme;

/**
 * \brief The global group for the entire document.
 */
FOUNDATION_EXPORT NSString * const PLThemeManagerSettings;

/**
 * \defgroup Theme_Manager_Properties Theme Manager Properties.
 * \brief The theme manager properties. These keywords specify the property of
 *        text component group (e.g. foreground and background colors).
 * @{
 */

/**
 * \brief The foreground color (i.e. font color).
 */
FOUNDATION_EXPORT NSString * const PLThemeManagerForeground;

/**
 * \brief The background color.
 */
FOUNDATION_EXPORT NSString * const PLThemeManagerBackground;

/**
 * \brief The line highlighting color.
 */
FOUNDATION_EXPORT NSString * const PLThemeManagerLineHighlight;

/**
 * \brief The color of selected text.
 */
FOUNDATION_EXPORT NSString * const PLThemeManagerSelection;

/**
 * @}
 */

@interface PLThemeManager : NSObject {
        /**
         * \brief Store the properties of the theme.
         */
        NSMutableDictionary * theme;
}

/**
 * \brief Returns the application's default theme manager.
 *
 * \details This method checks if the application default theme manager has
 *          been initialized. If the theme manager has not yet been initialized,
 *          it allocates and initializes a new theme manager by loading the 
 *          application's default theme. If the theme manager has already been
 *          initialized, it simply returns an instance to that object. The
 *          default theme manager does not do anything when release or retain
 *          messages are sent to it.
 *
 * \return A PLThemeManager object that is a reference to the application-wide
 *         default theme manager.
 */
+(id)defaultThemeManager;

/**
 * \brief Load a theme file into the theme instance variable
 *
 * \param path the path of the theme file to load.
 */
-(void)loadThemeAtPath:(NSString *)path;

/**
 * \brief Return the theme property from a keyword/property group.
 *
 * \param property the property of the text document.
 *
 * \param group the component of the text document, which has one or
 *        more properties.
 *
 * \return an NSColor* object for the requested property.
 */
-(NSColor *)getThemeProperty:(NSString *)property fromGroup:(NSString *)group;

-(NSGradient *)selectionGradient;

@end
