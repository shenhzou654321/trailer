
class StatusItemView: NSView {

	let statusLabel: String
	let textAttributes: Dictionary<String, AnyObject>
    var tappedCallback: (() -> Void)?
	let imagePrefix: String
	var labelOffset: CGFloat = 0

	init(frame: NSRect, label: String, prefix: String, attributes: Dictionary<String, AnyObject>) {
		imagePrefix = prefix
		statusLabel = label
		textAttributes = attributes
		highlighted = false
		grayOut = false
		darkMode = false
		super.init(frame: frame)
		darkMode = StatusItemView.checkDarkMode()
	}

	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	class func checkDarkMode() -> Bool {
		if NSAppKitVersionNumber>Double(NSAppKitVersionNumber10_9) {
			let c = NSAppearance.currentAppearance()
			if c.respondsToSelector(Selector("allowsVibrancy")) {
				return c.name.rangeOfString(NSAppearanceNameVibrantDark) != nil
			}
		}
		return false
	}

	var grayOut: Bool {
		didSet {
			if grayOut != oldValue {
				needsDisplay = true
			}
		}
	}

	var darkMode: Bool {
		didSet {
			if darkMode != oldValue {
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
					NSNotificationCenter.defaultCenter().postNotificationName(DARK_MODE_CHANGED, object:nil)
				}
			}
		}
	}

	var highlighted: Bool {
		didSet {
			if highlighted != oldValue {
				needsDisplay = true
			}
		}
	}

	override func mouseDown(theEvent: NSEvent) {
		if let t = tappedCallback { t() }
	}

	override func drawRect(dirtyRect: NSRect) {

		if(app.prStatusItem.view==self) {
			app.prStatusItem.drawStatusBarBackgroundInRect(dirtyRect, withHighlight: highlighted)
		} else {
			app.issuesStatusItem?.drawStatusBarBackgroundInRect(dirtyRect, withHighlight: highlighted)
		}

		darkMode = StatusItemView.checkDarkMode()

		let imagePoint = NSMakePoint(STATUSITEM_PADDING, 0)
		let labelRect = CGRectMake(bounds.size.height + labelOffset, -5, bounds.size.width, bounds.size.height)
		var displayAttributes = textAttributes
		var icon: NSImage

		if highlighted {
			icon = NSImage(named: "\(imagePrefix)IconBright")!
			displayAttributes[NSForegroundColorAttributeName] = NSColor.selectedMenuItemTextColor()
		} else {
			if darkMode {
				icon = NSImage(named: "\(imagePrefix)IconBright")!
				if displayAttributes[NSForegroundColorAttributeName] as NSColor == NSColor.controlTextColor() {
					displayAttributes[NSForegroundColorAttributeName] = NSColor.selectedMenuItemTextColor()
				}
			} else {
				icon = NSImage(named: "\(imagePrefix)Icon")!
			}
		}

		if grayOut {
			displayAttributes[NSForegroundColorAttributeName] = NSColor.disabledControlTextColor()
		}

		icon.drawAtPoint(imagePoint, fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeSourceOver, fraction: 1.0)
		statusLabel.drawInRect(labelRect, withAttributes: displayAttributes)
	}
}
