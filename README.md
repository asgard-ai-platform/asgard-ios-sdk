# AsgardCore

A modern iOS framework for building intelligent chatbot applications.

## Requirements

- iOS 14.0+
- Xcode 15.0+
- Swift 5.0+

## Dependencies

AsgardCore includes a customized version of the EventSource implementation. Please note:

- The framework includes a modified version of the EventSource implementation
- Do not install the original LDSwiftEventSource package alongside AsgardCore
- All EventSource related classes are prefixed with "Asgard" to avoid naming conflicts

## Installation

### CocoaPods

Add the following line to your Podfile:

```ruby
pod 'AsgardCore'
```

Then run:

```bash
pod install
```

### Manual Installation

1. Drag the AsgardCore project into your Xcode project
2. In Xcode:
   - Add AsgardCore as a target dependency
   - Set "Embed & Sign" in the framework's target settings
   - Add the framework to "Frameworks, Libraries, and Embedded Content"

## Usage

Import the framework in your Swift files:

```swift
import AsgardCore
```

### Basic Implementation

1. Create a chatbot instance with configuration:

```swift
// Create core configuration
let coreConfig = AsgardChatbotConfig(
    endpoint: "https://your-endpoint.com",
    botProviderEndpoint: "https://your-bot-provider.com",
    customChannelId: nil,
    onExecutionError: { error in
        print("Error : \(error.localizedDescription)")
    },
    transformSsePayload: { raw in
        print("SSE payload: \(raw)")
        // Process the raw SSE data here
        // This is where you can parse and handle the incoming messages
    },
    onReset: {
        print("Chatbot has been reset")
    },
    onClose: {
        print("Chatbot has been closed")
    }
)

// Get chatbot instance
let chatbot = Asgard.getChatbot(config: coreConfig)
```

2. Start the chatbot:

```swift
// Start the chatbot
chatbot.start()
```

3. Send messages:

```swift
// Send a message
chatbot.sendMessage("Hello!")
```

4. Manage chatbot lifecycle:

```swift
// Reset the chatbot
chatbot.reset()

// Close the chatbot
chatbot.closed()
```

### Logging

Set the log level for debugging:

```swift
Asgard.setLogLevel(.full)
```

## License

AsgardCore is available under the MIT license. See the LICENSE file for more info.
