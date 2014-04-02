/**
 * \file LiasisKit.h
 * \brief LiasisKit header file.
 *
 * \details Import all files for LiasisKit, the Liasis framework.
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

#import "PLThemeManager.h"
#import "PLThemeable.h"
#import "PLSyntaxHighlighter.h"

#import "PLDocumentManager.h"
#import "PLDocument.h"
#import "PLTextDocument.h"

#import "PLTabSubviewController.h"
#import "PLScroller.h"
#import "PLAutocompleteViewController.h"
#import "PLTextStorage.h"
#import "PLFormatter.h"
#import "PLLineNumberView.h"
#import "PLNavigationPopUpButton.h"
#import "PLNavigationItem.h"

#import "PLAddOnManager.h"
#import "PLAddOn.h"
#import "PLAddOnExtension.h"
#import "PLAddOnPlugin.h"

#import "NSTextView+characterRangeInRect.h"
#import "NSColor+hexToColor.h"
#import "NSDictionary+pythonDict.h"
#import "NSArray+pythonList.h"
#import "NSString+wordAtIndex.h"

/**
 * \defgroup Error_Domains Error Domains.
 * \brief The error domains for the application and LiasisKit.
 * @{
 */

/**
 * \brief The domain for errors in the Liasis application.
 */
FOUNDATION_EXPORT NSString * const PLLiasisErrorDomain;

/**
 * \brief The domain for errors in LiasisKit.
 */
FOUNDATION_EXPORT NSString * const PLLiasisKitErrorDomain;

/**
 * @}
 */

FOUNDATION_EXPORT NSString * const PLTabSubviewTitleDidChangeNotification;
FOUNDATION_EXPORT NSString * const PLTabSubviewDocumentChangedSavedSateNotification;

/**
 * \defgroup User_Defaults User Defaults.
 * \brief The user default keys for the application.
 * @{
 */

/**
 * \brief Key for determining if multiple instances of the same document can
 *        be open simultaneously.
 *
 * \details Maps to YES if a document can only be open once in the application.
 */
FOUNDATION_EXPORT NSString * const PLUserDefaultUniqueDocuments;

/**
 * @}
 */

/**
 * \brief The error codes used in errors from the application and LiasisKit.
 */
typedef enum {
        /**
         * \brief Urgent errors to be presented in a modal window.
         */
        PLErrorCodeModal,

        /**
         * \brief Normal errors to be presented in the application status bar.
         */
        PLErrorCodeStatusBar,

        /**
         * \brief Developer errors to be logged to the console.
         */
        PLErrorCodeLog
} PLErrorCode;
