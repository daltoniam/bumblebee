![bumblebee](http://idigitalcitizen.files.wordpress.com/2009/07/1920x1200-bumblebee88.jpg)


Bumblebee is an abstract text processing and pattern matching engine in Swift for iOS and OSX. This provides support for things like markdown and basic HTML tags to be properly converted from raw text to expected style using NSAttributedString. Example markdown engine is included.

## Features

- Abstract and simple. Creating patterns is simple, yet flexible.
- Fast. Only one pass is make through the raw string to minimize parse time.
- Simple concise codebase at just a few hundred LOC.

## Examples

First thing is to import the framework. See the Installation instructions on how to add the framework to your project.

```swift
import Bumblebee
```

This is a simple code example, but showcases a powerful use case.

```swift
//first we create our label to show our text
let label = UILabel(frame: CGRectMake(0, 65, view.frame.size.width, 400))
label.numberOfLines = 0
view.addSubview(label)

//we create this textAttachment to show our embedded image
var textAttachment = NSTextAttachment(data: nil, ofType: nil)

//the raw text we have.
let rawText = "Hello I am *red* and I am _bold_. Here is an image: ![](http://vluxe.io/assets/images/logo.png)"

//create our BumbleBee object.
let bee = BumbleBee()

//our red text pattern
bee.add("*?*", recursive: false) { (pattern: String, text: String, start: Int) -> (String, [NSObject : AnyObject]?) in
    let replace = pattern[advancedBy(pattern.startIndex, 1)...advancedBy(pattern.endIndex, -2)]
    return (replace,[NSForegroundColorAttributeName: UIColor.redColor()])
}
//the bold pattern
bee.add("_?_", recursive: false) { (pattern: String, text: String, start: Int) -> (String, [NSObject : AnyObject]?) in
    let replace = pattern[advancedBy(pattern.startIndex, 1)...advancedBy(pattern.endIndex, -2)]
    return (replace,[NSFontAttributeName: UIFont.boldSystemFontOfSize(17)])
}
//the image pattern
bee.add("![?](?)", recursive: false, matched: { (pattern: String, text: String, start: Int) in
    let range = pattern.rangeOfString("]")
    if let end = range {
        let findRange = pattern.rangeOfString("(")
        if let startRange = findRange {
            let url = pattern[advancedBy(startRange.startIndex, 1)..< advancedBy(pattern.endIndex, -1)]
			//using Skeets, we can easily fetch the remote image
            ImageManager.sharedManager.fetch(url, progress: { (Double) in
                }, success: { (data: NSData) in
                    let img = UIImage(data: data)
                    textAttachment.image = img
                    textAttachment.bounds = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
                    label.setNeedsDisplay() //tell our label to redraw now that we have our image
                }, failure: { (error: NSError) in
            })
        }
        return (bee.attachmentString,[NSAttachmentAttributeName: textAttachment]) // embed an attachment
    }
    return ("",nil) //don't change anything, not a match
})
//header pattern
bee.add("##?\n", recursive: false) { (pattern: String, text: String, start: Int) -> (String, [NSObject : AnyObject]?) in
    let replace = pattern[advance(pattern.startIndex, 2)...advance(pattern.endIndex, -2)]
    return (replace,[NSFontAttributeName: UIFont.systemFontOfSize(24)]) //whatever your large font is
}
//now that we have our patterns, we call process and get the NSAttributedString
let defaultAttrs = [NSFontAttributeName: UIFont.systemFontOfSize(18)] //default attributes to apply
let attrString = bee.process(rawText,attributes: defaultAttrs) //attributes can be omited if unneeded
label.attributedText = attrString
```

Which looks like:

![example](https://raw.githubusercontent.com/daltoniam/bumblebee/assets/example.png)

Image Loading Library:
[Skeets](https://github.com/daltoniam/Skeets)

## Details

The `?` is the wildcard. It is simply means that any character between these opening and closing characters could be a match.

## 

## Requirements

Bumblebee requires at least iOS 7/OSX 10.10 or above.

## Installation

### Cocoapods

Check out [Get Started](http://cocoapods.org/) tab on [cocoapods.org](http://cocoapods.org/).

To use Bumblebee in your project add the following 'Podfile' to your project

	source 'https://github.com/CocoaPods/Specs.git'
	platform :ios, '8.0'
	use_frameworks!

	pod 'Bumblebee', '~> 0.9.1'

Then run:

    pod install

### Carthage

Check out the [Carthage](https://github.com/Carthage/Carthage) docs on how to add a install. The `Bumblebee` framework is already setup with shared schemes.

[Carthage Install](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)

### Rogue

First see the [installation docs](https://github.com/acmacalister/Rogue) for how to install Rogue.

To install Bumblebee run the command below in the directory you created the rogue file.

```
rogue add https://github.com/daltoniam/bumblebee
```

Next open the `libs` folder and add the `Bumblebee.xcodeproj` to your Xcode project. Once that is complete, in your "Build Phases" add the `Bumblebee.framework` to your "Link Binary with Libraries" phase. Make sure to add the `libs` folder to your `.gitignore` file.

### Other

Simply grab the framework (either via git submodule or another package manager).

Add the `Bumblebee.xcodeproj` to your Xcode project. Once that is complete, in your "Build Phases" add the `Bumblebee.framework` to your "Link Binary with Libraries" phase.

### Add Copy Frameworks Phase

If you are running this in an OSX app or on a physical iOS device you will need to make sure you add the `Bumblebee.framework` included in your app bundle. To do this, in Xcode, navigate to the target configuration window by clicking on the blue project icon, and selecting the application target under the "Targets" heading in the sidebar. In the tab bar at the top of that window, open the "Build Phases" panel. Expand the "Link Binary with Libraries" group, and add `Bumblebee.framework`. Click on the + button at the top left of the panel and select "New Copy Files Phase". Rename this new phase to "Copy Frameworks", set the "Destination" to "Frameworks", and add `Bumblebee.framework`.

## TODOs

- [ ] Complete Docs
- [ ] Add Unit Tests
- [ ] Create full markdown engine example.

## License

Bumblebee is licensed under the Apache v2 License.

## Contact

### Dalton Cherry
* https://github.com/daltoniam
* http://twitter.com/daltoniam
* http://daltoniam.com
