#
# Be sure to run `pod lib lint XY_MessageCenter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XY_MessageCenter'
  s.version          = '0.1.0'
  s.summary          = 'XY_MessageCenter.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
XY_MessageCenter，封装了jpush,gcm,推送.
                       DESC

  s.homepage         = 'https://github.com/rRun/XY_MessageCenter'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'hexy' => 'hexy@cdfortis.com' }
  s.source           = {:git => "https://github.com/rRun/XY_MessageCenter.git", :tag => "#{s.version}" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'XY_MessageCenter/Classes/**/*','XY_MessageCenter/Lib/**/*.h'
  s.public_header_files = 'XY_MessageCenter/Classes/XY_MessageCenter.h'

  s.frameworks = "UIKit", "CFNetwork","CoreFoundation", "CoreTelephony","SystemConfiguration", "CoreGraphics","Foundation", "Security"
  s.libraries = "z"

  s.resource_bundles = {
    'XY_MessageCenter' => ['XY_MessageCenter/Assets/*']
  }

  s.vendored_libraries = "XY_MessageCenter/Lib/libjpush-ios-2.1.7.a"
  s.dependency "Firebase/Messaging"

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
