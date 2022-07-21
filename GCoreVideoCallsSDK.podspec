
Pod::Spec.new do |s|
  s.name             = 'GCoreVideoCallsSDK'
  s.version          = '2.5.1-xcframework'
  s.summary          = 'Video calls via WebRTC based on G-Core Labs services.'

  s.description      = <<-DESC
Video calls via WebRTC based on G-Core Labs services for iOS.
                       DESC

  s.homepage         = 'https://github.com/G-Core/ios-video-calls-SDK'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'EvgenPol' => 'evgeniy.polubin@gcorelabs.com' }
  s.source           = { :git => 'https://github.com/G-Core/ios-video-calls-SDK/blob/main/GCoreVideoCallsSDK.xcframework.zip', :tag => s.version.to_s }
  s.swift_version      = '5.3'
  s.vendored_frameworks = "GCoreVideoCallsSDK.xcframework"
  s.ios.deployment_target = '12.0'
  s.requires_arc          = true

end
