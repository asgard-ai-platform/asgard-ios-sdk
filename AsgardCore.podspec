Pod::Spec.new do |s|
  s.name             = 'AsgardCore'
  s.version          = '0.0.9'
  s.summary          = 'AsgardCore is a comprehensive iOS SDK that provides chatbot functionality and real-time communication capabilities.'
  s.description      = 'AsgardCore is a powerful iOS SDK that enables developers to easily integrate chatbot functionality into their applications. It provides real-time communication capabilities using Server-Sent Events (SSE), making it ideal for building interactive chat interfaces. The SDK includes features such as session management, token-based authentication, and automatic reconnection handling. It is designed to be easy to integrate and use, with a clean and intuitive API.'
  s.homepage         = 'https://www.asgard-ai.com/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'INK' => 'inktu777@gmail.com' }
  s.source       = {
    :git => 'https://github.com/asgard-ai-platform/asgard-ios-sdk.git',
    :tag => "#{s.version}" 
  }
  s.swift_version    = '5.0'
  s.platform         = :ios, '13.0'
  s.vendored_frameworks = 'AsgardCore.xcframework'
end
