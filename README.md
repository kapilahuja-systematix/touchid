## TouchID

iOS8 TouchID with just few lines of code

![Default](https://raw.github.com/bvogelzang/SevenSwitch/master/ExampleImages/example.png)

## Usage

### Without Cocoapods

Add `TouchID.swift` to your project.

### Examples

Initializing and adding the switch to the screen

```swift
@IBOutlet var touchAuthentication: TouchID! = TouchID.sharedInstance
```

Check whether a passcode is set for your application or not with `touchAuthentication.isPasscodeSetup()`.
If not set, then setup it with `touchAuthentication.setupPassword()` and for using device Touch Finger use `touchAuthentication.authenticateUser()`.

```swift
if !touchAuthentication.isPasscodeSetup() {
touchAuthentication.setupPassword()
}else{
touchAuthentication.authenticateUser()
}
```

Define `TouchIDDelegate` Delegate to get all the success and fail responses.

```swift
class ViewController: UIViewController, TouchIDDelegate

touchAuthentication.touchDelegate = self
```

Delegate Methods (All are optional)

```swift
func TouchIDSuccedd()
func TouchIDFail(ErrorMessage: String)
func PasscodeSuccedd()
func PasscodeFail(ErrorMessage: String)
func SetUpPasscodeSuccedd()
func SetUpPasscodeFail(ErrorMessage: String)
func ChangePasscodeSuccedd()
func ChangePasscodeFail(ErrorMessage: String)
func SetingsPopUpResponse(Message: String)
```

Use like

```swift
//MARK:- TouchIDDelegate

func TouchIDSuccedd() {
// Implementation After Authentication Pass
}

func TouchIDFail(ErrorMessage: String) {
// Authentication Fail/Error
print("\(ErrorMessage)")
}
``````

## Swift and Objective-C compatability

TouchID uses Swift as of its 3.0 release. TouchID.swift can be used in Objective-C using Swift Objective-C bridging.

## Requirements

TouchID requires iOS 8.0 and above.

## License

Made available under the MIT License. Attribution would be nice.
