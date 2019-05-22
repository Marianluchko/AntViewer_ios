#
# Be sure to run `pod lib lint AntViewer_ios.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AntViewer_ios'
  s.version          = '0.3.1'
  s.summary          = 'AntViewer provides to users possibility to watch streams and use chat and polls'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                        AntViewer provides to users possibility to watch streams and use chat and polls.
                       DESC

  s.homepage         = 'https://github.com/kolyan94'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mykola Vaniurskyi' => 'mv@leobit.co' }
  s.source           = { :git => 'https://github.com/kolyan94/AntViewer_ios.git', :tag => s.version.to_s }

  s.platform     = :ios, "11.3"
  s.source_files = 'AntViewer_ios/Classes/**/*.{swift,h}'
  s.ios.vendored_frameworks = 'AntViewer_ios/MyFrameworks/AntViewerExt.framework', 'AntViewer_ios/MyFrameworks/Lottie.framework'

  s.resources = 'AntViewer_ios/Classes/**/*.{storyboard,xib,plist}'
  s.resource_bundles = {
    'AntWidget' => ['AntViewer_ios/Assets/*']
  }
  s.pod_target_xcconfig = {'DEFINES_MODULE' => 'YES'}
  #'AntViewer_ios/Assets/*',
  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.static_framework = true
  s.xcconfig = { 'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/Firebase/CoreOnly/Sources',
    'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/Firebase/CoreOnly/Sources'
  }
  s.public_header_files = 'AntViewer_ios/Classes/*.h'
  s.frameworks = 'UIKit', 'AVKit'
  s.dependency 'Firebase/Core', '~> 5.11'
  s.dependency 'Firebase/Database', '~> 5.11'
  s.swift_version = "5"
end
