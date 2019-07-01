# AntViewer_ios

[![Version](https://img.shields.io/cocoapods/v/AntViewer_ios.svg?style=flat)](https://cocoapods.org/pods/AntViewer_ios)
[![License](https://img.shields.io/cocoapods/l/AntViewer_ios.svg?style=flat)](https://cocoapods.org/pods/AntViewer_ios)
[![Platform](https://img.shields.io/cocoapods/p/AntViewer_ios.svg?style=flat)](https://cocoapods.org/pods/AntViewer_ios)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 11.3 +

## Installation

AntViewer_ios is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:
`pod 'AntViewer_ios'`.
And run `$ pod install`

## Usage

Programmatically: 
```swift
class ViewController: UIViewController {

  var widget: AntWidget! {
    didSet {
      view.addSubview(widget)
      widget.bottomMargin = 30
      widget.rightMargin = 40
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    widget = AntWidget()
    widget.onViewerAppear = { [weak self] _ in
      self?.changeSomething()
    }
  }
}
```
Or by interface builder: 
Just add UIView, type AntWidget to class field, link to outlet. Thats all.



| Property          | Type     | Description                                                            |
|-------------------|----------|------------------------------------------------------------------------|
| isLightMode       | Bool     | There are two widget appearance modes: light & dark. By default false. |
| bottomMargin      | Int   | Bottom margin. Default: 20.                                            |
| rightMargin       | Int   | Right margin. Default: 20.                                             |
| onViewerAppear    | Closure | Called when the user opens the widget controller.                      |
| onViewerDisappear | Closure | Called when the user dismisses the widget controller.                  |


## Author

Mykola Vaniurskyi, mv@leobit.com

## License

AntViewer_ios is available under the MIT license. See the LICENSE file for more info.
