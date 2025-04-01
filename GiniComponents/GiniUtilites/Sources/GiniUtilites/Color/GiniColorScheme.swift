//
//  GiniColorScheme.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public struct GiniColorScheme {
    public struct Background {
        public var primary: GiniColor
        public var secondary: GiniColor
        
        public init(primary: GiniColor, secondary: GiniColor) {
            self.primary = primary
            self.secondary = secondary
        }
    }

    public struct ActionSheet {
        public var buttonBackground: GiniColor
        public var cancelButtonBackground: GiniColor
        
        public init(buttonBackground: GiniColor, cancelButtonBackground: GiniColor) {
            self.buttonBackground = buttonBackground
            self.cancelButtonBackground = cancelButtonBackground
        }
    }

    public struct Alert {
        public var background: GiniColor
        public var divider: GiniColor
        
        public init(background: GiniColor, divider: GiniColor) {
            self.background = background
            self.divider = divider
        }
    }

    public struct NavigationBar {
        public var background: GiniColor
        public var action: GiniColor
        public var navigation: GiniColor
        
        public init(background: GiniColor, action: GiniColor, navigation: GiniColor) {
            self.background = background
            self.action = action
            self.navigation = navigation
        }
    }

    public struct Content {
        public var navigation: GiniColor
        public var text: GiniColor
        
        public init(navigation: GiniColor, text: GiniColor) {
            self.navigation = navigation
            self.text = text
        }
    }

    public struct BottomBar {
        public var background: GiniColor
        public var border: GiniColor
        
        public init(background: GiniColor, border: GiniColor) {
            self.background = background
            self.border = border
        }
    }
    
    public struct Container {
        public var background: GiniColor
        
        public init(background: GiniColor) {
            self.background = background
        }
    }

    public struct Placeholder {
        public var background: GiniColor
        public var tint: GiniColor
        
        public init(background: GiniColor, tint: GiniColor) {
            self.background = background
            self.tint = tint
        }
    }

    public struct Text {
        public var primary: GiniColor
        public var secondary: GiniColor
        public var tertiary: GiniColor
        public var accent: GiniColor
        public var success: GiniColor
        public var error: GiniColor
        
        public init(primary: GiniColor, secondary: GiniColor, tertiary: GiniColor, accent: GiniColor, success: GiniColor, error: GiniColor) {
            self.primary = primary
            self.secondary = secondary
            self.tertiary = tertiary
            self.accent = accent
            self.success = success
            self.error = error
        }
    }

    public struct Icon {
        public var primary: GiniColor
        public var secondary: GiniColor
        
        public init(primary: GiniColor, secondary: GiniColor) {
            self.primary = primary
            self.secondary = secondary
        }
    }

    public struct PageController {
        public var selected: GiniColor
        public var unselected: GiniColor
        
        public init(selected: GiniColor, unselected: GiniColor) {
            self.selected = selected
            self.unselected = unselected
        }
    }

    public struct Error {
        public var background: GiniColor
        public var icon: GiniColor
        
        public init(background: GiniColor, icon: GiniColor) {
            self.background = background
            self.icon = icon
        }
    }

    public struct Message {
        public var backgroundSuccess: GiniColor
        public var contentSuccess: GiniColor
        public var backgroundWarning: GiniColor
        public var contentWarning: GiniColor
        public var backgroundError: GiniColor
        public var contentError: GiniColor
        
        public init(backgroundSuccess: GiniColor, contentSuccess: GiniColor, backgroundWarning: GiniColor, contentWarning: GiniColor, backgroundError: GiniColor, contentError: GiniColor) {
            self.backgroundSuccess = backgroundSuccess
            self.contentSuccess = contentSuccess
            self.backgroundWarning = backgroundWarning
            self.contentWarning = contentWarning
            self.backgroundError = backgroundError
            self.contentError = contentError
        }
    }

    public struct Badge {
        public var background: GiniColor
        public var content: GiniColor
        
        public init(background: GiniColor, content: GiniColor) {
            self.background = background
            self.content = content
        }
    }

    public struct Button {
        public var background: GiniColor
        public var backgroundLoading: GiniColor
        public var content: GiniColor
        
        public init(background: GiniColor, backgroundLoading: GiniColor, content: GiniColor) {
            self.background = background
            self.backgroundLoading = backgroundLoading
            self.content = content
        }
    }

    public struct ButtonOutlined {
        public var background: GiniColor
        public var content: GiniColor
        
        public init(background: GiniColor, content: GiniColor) {
            self.background = background
            self.content = content
        }
    }

    public struct TextField {
        public var background: GiniColor
        public var border: GiniColor
        public var focusedText: GiniColor
        public var unfocusedText: GiniColor
        public var disabledText: GiniColor
        public var errorText: GiniColor
        public var labelFocused: GiniColor
        public var labelUnfocused: GiniColor
        public var labelDisabled: GiniColor
        public var labelError: GiniColor
        public var supportingFocused: GiniColor
        public var supportingUnfocused: GiniColor
        public var supportingDisabled: GiniColor
        public var supportingError: GiniColor
        public var trailingFocused: GiniColor
        public var cursorEnabled: GiniColor
        public var cursorError: GiniColor
        
        public init(background: GiniColor, border: GiniColor, focusedText: GiniColor, unfocusedText: GiniColor, disabledText: GiniColor, errorText: GiniColor, labelFocused: GiniColor, labelUnfocused: GiniColor, labelDisabled: GiniColor, labelError: GiniColor, supportingFocused: GiniColor, supportingUnfocused: GiniColor, supportingDisabled: GiniColor, supportingError: GiniColor, trailingFocused: GiniColor, cursorEnabled: GiniColor, cursorError: GiniColor) {
            self.background = background
            self.border = border
            self.focusedText = focusedText
            self.unfocusedText = unfocusedText
            self.disabledText = disabledText
            self.errorText = errorText
            self.labelFocused = labelFocused
            self.labelUnfocused = labelUnfocused
            self.labelDisabled = labelDisabled
            self.labelError = labelError
            self.supportingFocused = supportingFocused
            self.supportingUnfocused = supportingUnfocused
            self.supportingDisabled = supportingDisabled
            self.supportingError = supportingError
            self.trailingFocused = trailingFocused
            self.cursorEnabled = cursorEnabled
            self.cursorError = cursorError
        }
    }

    public struct Toggle {
        public var thumb: GiniColor
        public var trackOn: GiniColor
        public var trackOff: GiniColor
        public var disabledTrack: GiniColor
        
        public init(thumb: GiniColor, trackOn: GiniColor, trackOff: GiniColor, disabledTrack: GiniColor) {
            self.thumb = thumb
            self.trackOn = trackOn
            self.trackOff = trackOff
            self.disabledTrack = disabledTrack
        }
    }

    public var background: Background
    public var actionSheet: ActionSheet
    public var alert: Alert
    public var navigationBar: NavigationBar
    public var content: Content
    public var bottomBar: BottomBar
    public var container: Container
    public var placeholder: Placeholder
    public var text: Text
    public var icon: Icon
    public var pageController: PageController
    public var error: Error
    public var message: Message
    public var badge: Badge
    public var button: Button
    public var buttonOutlined: ButtonOutlined
    public var textField: TextField
    public var toggle: Toggle
    
    public init(background: Background, actionSheet: ActionSheet, alert: Alert, navigationBar: NavigationBar, content: Content, bottomBar: BottomBar, container: Container, placeholder: Placeholder, text: Text, icon: Icon, pageController: PageController, error: Error, message: Message, badge: Badge, button: Button, buttonOutlined: ButtonOutlined, textField: TextField, toggle: Toggle) {
        self.background = background
        self.actionSheet = actionSheet
        self.alert = alert
        self.navigationBar = navigationBar
        self.content = content
        self.bottomBar = bottomBar
        self.container = container
        self.placeholder = placeholder
        self.text = text
        self.icon = icon
        self.pageController = pageController
        self.error = error
        self.message = message
        self.badge = badge
        self.button = button
        self.buttonOutlined = buttonOutlined
        self.textField = textField
        self.toggle = toggle
    }
}
