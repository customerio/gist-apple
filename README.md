# Gist for iOS & iPadOS
Gist gives you access to a library of ready built micro-experiences that can be easily dropped into your application without writing a line of code.

## Installation
```ruby
pod 'Gist', '~> 0.2.1'
```

## Setup
In your `AppDelegate` add Gist as a stored property and initialize it inside the application’s `didFinishLaunchingWithOptions` method.

- The `organizationId` property can be retrieved from the Gist dashboard.
- Logging is optional.

```swift
var gist: Gist!
func application(_ application: UIApplication, 
                  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        gist = Gist(organizationId: "Your-Key", logging: true)
        gist.setup()

        return true
}
```

### User Token
If your app is relying on Gist’s web hook service to trigger in-app messages, a user token must be set. This user token should be generated by your services and set at any point during runtime, ex: login or registration.

```swift
gist.setUserToken(userToken: "Unique-User-Token")
```

## Manually Triggering In-App Messages
Gist gives you the option to programmatically trigger in-app messaging flows within your app.

### Show Message
```swift
gist.showMessage(messageRoute: "message-id")
```

### Dismiss Message
```swift
gist.dismissMessage()
```

These methods should only be used to trigger flows programmatically, if you wish to create an integration with a custom CRM, see Integrations section below.

## Event Handling
The framework exposes a delegate which you can hook into, this gives you the option to know when a message is shown, dismissed or when an action occurs within the message.

```swift
public protocol GistDelegate: AnyObject {
    func messageShown(messageRoute: String)
    func messageDismissed(messageRoute: String)
    func messageError(messageRoute: String)
    func action(action: String)
}
```

## Integrations
The `GistExtendable` protocol enables you to plug in external integrations that trigger in-app messages from external sources.

```swift
public protocol GistExtendable {
    var name: String {get set}
    init(gist: Gist)
    func setup()
    func messageShown(messageRoute: String, userToken: String?)
    func messageDismissed(messageRoute: String, userToken: String?)
    func actionPerformed(action: String)
}
```

To activate your extension you need to include it in Gist initialization.

```swift
gist = Gist(organizationId: "Your-Key",
            extensions: [YourIntegration.self],
            logging: true)
```

On framework bootstrap the `setup` function is triggered, this can be used to start listeners.

### A list of available integrations can be found below:
- [Gist Firebase](https://gitlab.com/bourbonltd/gist-firebase-apple)
