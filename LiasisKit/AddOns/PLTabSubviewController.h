/**
 * \file PLTabSubviewController.m
 * \brief Liasis Python IDE tab subview controller protocol file.
 *
 * \details This protocol file specifies all the methods that must be 
 *          implemented by view controllers that interact with the tab view
 *          object.
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
 * \note This interface is very rough and will be changed significantly in
 *       upcoming versions of the IDE. Its current state is intended for use with
 *       view extensions, opposite to what the protocol name suggests.
 *
 */
#import <Foundation/Foundation.h>
#import "PLThemeable.h"
#import "PLDocument.h"

@protocol PLTabSubviewController <NSObject, PLThemeable>

/**
 * \brief Factory method used to initialize a new tab subview controller.
 *
 * \details This method is used to initialize a new instance of the tab 
 *          subview controller that must be in a useable state. This usually
 *          implies that the tab subview controller has loaded its
 *          corresponding nib file and any instance variables that are
 *          necessary.
 *
 * \return An instance of an object that condorms to the PLTabSubviewController
 *         protocol.
 */
+(id)viewController;

/**
 * \brief Factory method used to initialize a new tab subview controller.
 *
 * \details This method is used to initialize a new instance of the tab
 *          subview controller that must be in a useable state. This usually
 *          implies that the tab subview controller has loaded its
 *          corresponding nib file and any instance variables that are
 *          necessary.
 *
 * \return An instance of an object that condorms to the PLTabSubviewController
 *         protocol.
 */
+(id)viewControllerWithDocument:(id)document;

/**
 * \brief Factory method used to initialize a new tab subview controller.
 *
 * \details This method is used to initialize a new instance of the tab
 *          subview controller that must be in a useable state. This usually
 *          implies that the tab subview controller has loaded its
 *          corresponding nib file and any instance variables that are
 *          necessary.
 *
 * \return An instance of an object that condorms to the PLTabSubviewController
 *         protocol.
 *
 * \todo Remove the dependency on the theme manager and on the bundle information,
 *       as both can be removed by changing their corresponding data is
 *       retrieved. A new method "viewController" will be used in future versions.
 *       This change will make the division between tab subview controller and
 *       view extension much clearer.
 */
+(NSString *)tabSubviewName;

/**
 * \brief Method used to retrieve the actual view that is controlled by the object
 *        conforming to this protocol.
 *
 * \return An NSView object. that can be displayed, typically within the tab view.
 *
 */
-(NSView *)view;

/**
 * \brief Method used to relay NSEvents that are created from pressing the keyborad.
 *
 * \return A BOOL variable with YES if the tab subview controller responded to 
 *         the key equivalent. Otherwise, returns NO.
 *
 */
-(BOOL)performKeyEquivalent:(NSEvent *)theEvent;

/**
 * \brief Method called by tab view controller to change the name of the tab.
 *
 * \details This method is called by the tab view controllerto obtain the 
 *          title of the tab. The tab viw checks if the tab view title needs
 *          updating frequently, and therefore the title may change as different
 *          actions are performed by the tab view.
 *
 * \return An NSString * object containing the title of the tab subview controlled
 *         by the subview controller.
 *
 */
-(NSString *)title;

/**
 * \brief Method called by tab view controller prior to removing a tab view item.
 *
 * \details This method is called by the tab view controller prior to removing a
 *          tab subview. The receiver, the subviw controller, may then perform
 *          actions prior to closing the tab. If the subview should not close,
 *          the receiver must return NO.
 *
 * \param id sender The object that sent the close message.
 *
 * \return A BOOL value indicating whether or not the tab subview should close.
 *         If YES, the tab view controller removes the tab subview. If NO, the
 *         tab subview is not removed and nothing is done.
 *
 */
-(BOOL)tabSubviewShouldClose:(id)sender;

/**
 * \brief Method called by tab view controller when a file should be saved.
 *
 * \details This method is called by the tab view controller when a save event
 *          is intercepted, either by key equivalents or (TO DO) through the
 *          menu bar. The receiver, the subviw controller, may
 *          choose to take action, or ignore the command.
 *
 * \param id sender The object that sent the open message.
 */
-(IBAction)saveFile:(id)sender;

/**
 * \brief Method called by tab view controller when a file should be saved as a
 *        new file.
 *
 * \details This method is called by the tab view controller when a save as event
 *          is intercepted, either by key equivalents or (TO DO) through the
 *          menu bar. The receiver, the subviw controller, may
 *          choose to take action, or ignore the command.
 *
 * \param id sender The object that sent the open message.
 */
-(IBAction)saveFileAs:(id)sender;


-(PLDocument <PLDocumentSubclass> *)document;

@end
