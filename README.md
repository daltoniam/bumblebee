![bumblebee](http://idigitalcitizen.files.wordpress.com/2009/07/1920x1200-bumblebee88.jpg)


Bumblebee is an abstract text processing and pattern matching engine in Swift for iOS and OSX. This provides support for things like markdown and basic HTML tags to be properly converted from raw text to expected style using NSAttributedString. Example markdown engine is included. 

## Features

- Abstract and simple. Creating patterns is simple, yet flexible.
- Fast. Only one pass is make through the raw string to minimize parse time.
- Simple concise codebase at just a few hundred LOC.

## Examples

First thing is to import the framework. See the Installation instructions on how to add the framework to your project.

```swift
//iOS
import Bumblebee
//OS X
import BumblebeeOSX
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
    let replace = pattern[advance(pattern.startIndex, 1)...advance(pattern.endIndex, -2)]
    return (replace,[NSForegroundColorAttributeName: UIColor.redColor()])
}
//the bold pattern
bee.add("_?_", recursive: false) { (pattern: String, text: String, start: Int) -> (String, [NSObject : AnyObject]?) in
    let replace = pattern[advance(pattern.startIndex, 1)...advance(pattern.endIndex, -2)]
    return (replace,[NSFontAttributeName: UIFont.boldSystemFontOfSize(17)])
}
//the image pattern
bee.add("![?](?)", recursive: false, matched: { (pattern: String, text: String, start: Int) in
    let range = pattern.rangeOfString("]")
    if let end = range {
        let findRange = pattern.rangeOfString("(")
        if let startRange = findRange {
            let url = pattern[advance(startRange.startIndex, 1)..< advance(pattern.endIndex, -1)]
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
//now that we have our patterns, we call process and get the NSAttributedString
let attrString = bee.process(rawText)
label.attributedText = attrString
```

Which looks like:

![example](https://raw.githubusercontent.com/daltoniam/bumblebee/assets/example.png)

Image Loading Library:
[Skeets](https://github.com/daltoniam/Skeets)

## Details

The `?` is the wildcard. It is simply means that any character between these opening and closing characters could be a match.

## Requirements

Bumblebee requires at least iOS 7/OSX 10.10 or above.

## Installation

### Cocoapods

### [CocoaPods](http://cocoapods.org/) 
At this time, Cocoapods support for Swift frameworks is supported in a [pre-release](http://blog.cocoapods.org/Pod-Authors-Guide-to-CocoaPods-Frameworks/).

To use Bumblebee in your project add the following 'Podfile' to your project

    source 'https://github.com/CocoaPods/Specs.git'

    xcodeproj 'YourProjectName.xcodeproj'
    platform :ios, '8.0'

    pod 'Bumblebee', :git => "https://github.com/daltoniam/bumblebee.git", :tag => "0.9.1"

    target 'YourProjectNameTests' do
        pod 'Bumblebee', :git => "https://github.com/daltoniam/bumblebee.git", :tag => "0.9.1"
    end

Then run:

    pod install

#### Updating the Cocoapod
You can validate Bumblebee.podspec using:

    pod spec lint Bumblebee.podspec

This should be tested with a sample project before releasing it. This can be done by adding the following line to a ```Podfile```:
    
    pod 'Bumblebee', :git => 'https://github.com/username/bumblebee.git'

Then run:
    
    pod install

If all goes well you are ready to release. First, create a tag and push:

    git tag 'version'
    git push --tags

Once the tag is available you can send the library to the Specs repo. For this you'll have to follow the instructions in [Getting Setup with Trunk](http://guides.cocoapods.org/making/getting-setup-with-trunk.html).

    pod trunk push Bumblebee.podspec

### Carthage

Check out the [Carthage](https://github.com/Carthage/Carthage) docs on how to add a install. The `Bumblebee` framework is already setup with shared schemes.

[Carthage Install](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)

### Rogue

First see the [installation docs](https://github.com/acmacalister/Rogue) for how to install Rogue.

To install JSONJoy run the command below in the directory you created the rogue file.

```
rogue add https://github.com/daltoniam/bumblebee
```

Next open the `libs` folder and add the `Bumblebee.xcodeproj` to your Xcode project. Once that is complete, in your "Build Phases" add the `Bumblebee.framework` to your "Link Binary with Libraries" phase. Make sure to add the `libs` folder to your `.gitignore` file.

### Other

Simply grab the framework (either via git submodule or another package manager).

Add the `Bumblebee.xcodeproj` to your Xcode project. Once that is complete, in your "Build Phases" add the `Bumblebee.framework` to your "Link Binary with Libraries" phase.


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
