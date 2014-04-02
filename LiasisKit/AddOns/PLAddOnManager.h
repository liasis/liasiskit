/**
 * \file PLAddOnManager.h
 * \brief Add on manager headerfile.
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

/**
 * \brief An NSString used as the notification name, used whenever the
 *        add-on manager loaded a new add-on.
 */
FOUNDATION_EXPORT NSString * const PLAddOnManagerDidLoadNotification;

/**
 * \class PLAddOnManager \headerfile \headerfile
 *
 * \brief A class used to manage (currently only used to load) external add-on's.
 *
 * \details This class is used to load and unload add-ons, detect available
 *          add-ons, as well as determining the type of add-on for each of the
 *          available add-ons. The add-ons types currently supported are defined
 *          in the PLAddOn protocol file.
 *
 * \note The add-on manager is currently in a very early state and will change 
 *       significantly.
 *
 * \todo Improve the add on manager loading unloading functionality.
 *
 */
@interface PLAddOnManager : NSObject {
        @private
        /**
         * \brief Instance variable used to store the add-ons that have been
         *        loaded, and link the name of the add-on with its corresponding 
         *        bundle.
         */
        NSMutableDictionary * loadedAddOns;
        
        NSMutableDictionary * defaultExtensionForFileType;
}

/**
 * \brief The default `NSBundle` used for launching new tabs.
 *
 * \details The `PLTabViewController` extracts the principal class from the
 *          default tab bundle and sends it a `viewController` message to
 *          instantiate a new tab subview controller to display. The bundle's
 *          principal class must conform to the `PLAddOnViewExtension` protocol.
 *
 *          The first bundle loaded with `loadAddOnNamed:` meeting the above
 *          requirement becomes the default bundle if this has not been set
 *          previously. This property will return nil until one is loaded.
 */
@property (retain) NSBundle * defaultAddOnBundle;

/**
 * \brief Method to retrieve the application's default add on manager.
 *
 * \details The default add-on manager is set up upon initial call to this method
 *          and is intended to be used as the only instance of the add-on manager
 *          class. However, new add on manager's can be created, and loading 
 *          add-ons is currently global, as it involves loading the code
 *          associated with the bundle.
 *
 * \return An instance of the application default add on manager object.
 *
 * \todo Set up that loaded add-ons can be either set to on or off, and thus
 *       loading will be independent of wether an add on manager has the
 *       add-on set as on or off.
 */
+(id)defaultManager;

/**
 * \brief Method to retrieve the number of available add-ons.
 *
 * \return An NSUInteger with the number of available add-ons at the
 *         default add-on path.
 *
 * \see numberOfAddOns
 */
-(NSUInteger)numberOfAddOns;

/**
 * \brief Returns the name of the available add-ons at the default add on path.
 *
 * \details This method identifies all the add-ons in the default application
 *          plugin path in the resources directory. The available add-ons are
 *          identified by the application if they have the ".plugin" extension.
 *
 * \return An NSArray object containing the names of all the available add-ons
 *         at the default add-on path.
 */
-(NSArray *)availableAddOns;

/**
 * \brief Method to check if add on manager loaded a specific add on with a 
 *        given name.
 *
 * \details This method identifies all the add-ons in the default application
 *          plugin path in the resources directory. The available add-ons are
 *          identified by the application if they have the ".plugin" extension.
 *
 * \param addOnName An NSString object containing the name of the add on
 *                  that is to be checked for a loaded status.
 *
 * \return Method returs YES if the specified add on was loaded succesfully.
 *         Otherwise, method return NO.
 */
-(BOOL)didLoadAddOnWithName:(NSString *)addOnName;

/**
 * \brief Method to retrieve the names of all loaded add ons.
 *
 * \return Returns an NSArray with each entry in the array being the name of a
 *         loaded add on.
 */
-(NSArray *)loadedAddOns;

/**
 * \brief Method to retrieve the bundle for a specific loaded add on.
 *
 * \param bundleName An NSString with the name of a add on that has been loaded.
 *
 * \return If there is a loaded add on with the given name, the method returns
 *         the NSBundle whose principal class is the add ons primary controller.
 *         If the add on has not been loaded, nil is returned.
 */
-(NSBundle *)loadedAddOnNamed:(NSString *)bundleName;

/**
 * \brief Method to retrieve the names of all loaded view extension add ons.
 *
 * \return Returns an NSArray with each entry in the array being the name of a
 *         loaded view extension add on.
 */
-(NSArray *)extensionBundles;

/**
 * \brief Method to load an add on with a given name.
 *
 * \details The method loads the add-on bundle's object code and saves a reference 
 *          of the bundle in the loaded add on mutable array. The bundle that
 *          is loaded must have designated its principal class as the add on's 
 *          primary controller object.
 *
 *          The first time this is called, set the loaded bundle as the
 *          `defaultAddOnBundle` if the bundle's principal class conforms to the
 *          `PLAddOnExtension` protocol unless the property has already been
 *          set.
 *
 * \param bundleName An NSString object containing the name of the add on, and
 *                   therefore the bundle, that will be loaded.
 *
 * \return Returns the NSBundle whose principal class is the add-ons primary 
 *         controller. If the add on has not been loaded, nil is returned.
 */
-(NSBundle *)loadAddOnNamed:(NSString *)bundleName;

/**
 * \brief Method to return all the allowed file types that can be opened by the
 *        loaded add-ons.
 *
 * \return Returns an `NSArray` where each entry is an allowed filetype
 *         extension. If there are non defined, return an empty array.
 *
 * \see PLAddOnManager::allowedFileTypesForAddOn:
 */
-(NSArray *)allAllowedFileTypes;

/**
 * \brief Method to return all the allowed file types that can be opened by
 *        a specific add-on.
 *
 * \details The method loads the data in an add-on's Info plist file
 *          to determine all the file types that can be opened by Liasis. The 
 *          entry in the plist that corresponds to the allowed file types
 *          is defined in the constant `PLAddOnAllowedFileTypesName`.
 *
 * \param addOn The NSBundle of a loaded add-on for which an array of allowed
 *              file types will be obtained.
 *
 * \return Returns an `NSArray` where each entry is an allowed filetype
 *         extension. If there are non defined, return an empty array.
 *
 * \see PLAddOnAllowedFileTypesName
 */
-(NSArray *)allowedFileTypesForAddOn:(NSBundle *)addOn;

/**
 * \brief Method to return the appropriate document class that can be used
 *        by a specific add-on.
 *
 * \details The method loads the data in an add-on's Info plist file
 *          to determine the document class used by that add-on. The
 *          entry in the plist that corresponds to its compatible document class
 *          is defined in the constant `PLAddOnDocumentClassName`.
 *
 * \param addOn The `NSBundle` of a loaded add-on for which the document class
 *              used by that add-on will be obtained.
 *
 * \return Returns a `Class` reference for the compatible document class used by
 *         the add-on. If none is defined, return `NIL`.
 *
 * \see PLAddOnDocumentClassName
 */
-(Class)documentClassForAddOn:(NSBundle *)addOn;

/**
 * \brief Convenience method that returns the prefered add-on for a 
 *        specific file type.
 *
 * \return The NSBundle that is the default add-on for the file type. If no
 *         add-on was found, returns nil.
 */
-(NSBundle *)defaultAddOnForFileType:(NSString *)fileType;

@end
