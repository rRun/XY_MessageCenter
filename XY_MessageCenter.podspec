#
# Be sure to run `pod lib lint XY_MessageCenter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XY_MessageCenter'
  s.version          = '0.0.1'
  s.summary          = 'XY_MessageCenter'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
            XY_MessageCenter，封装了jpush,gcm,推送
                       DESC

  s.homepage         = 'https://github.com/rRun/XY_MessageCenter'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'hexy' => 'hexy@cdfortis.com' }
  s.source       = { :git => "https://github.com/rRun/XY_MessageCenter.git", :tag => "#{s.version}" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'Classes/Classes/**/*','Classes/Lib/**/*.h'
  s.preserve_paths = "Classes/Lib/**/*"
  s.vendored_frameworks = "Classes/Lib/**/*.framework"
    s.vendored_libraries = "Classes/Lib/XY_JPUSH/libjpush-ios-2.1.7.a"
  s.resource_bundles = {
    'XY_MessageCenter' => ['Classes/Assets/*']
  }

    s.public_header_files = 'Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
    s.frameworks = "AdSupport","UIKit","AudioToolbox", "CFNetwork","CoreFoundation", "CoreTelephony","SystemConfiguration", "CoreGraphics","Foundation", "Security"
    s.libraries = "z"
  # s.dependency 'AFNetworking', '~> 2.3'
    s.dependency "Firebase/Messaging"
  #  s.dependency "XY_JPUSH"
  #  因为该混用framework,.a库混用出现问题，只能手动倒入.a库

    # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
end
