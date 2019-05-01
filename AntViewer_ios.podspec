#
# Be sure to run `pod lib lint AntViewer_ios.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AntViewer_ios'
  s.version          = '0.1.6'
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
  s.source_files = 'AntViewer_ios/Classes/**/*.{swift}'
  s.ios.vendored_frameworks = 'AntViewer_ios/MyFrameworks/AntViewerExt.framework'
  #s.pod_target_xcconfig = { 'VALID_ARCHS[sdk=iphonesimulator*]' => '' }

  s.resources = 'AntViewer_ios/Assets/*', 'AntViewer_ios/Classes/**/*.{storyboard,xib,plist}'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.static_framework = true
  s.frameworks = 'UIKit', 'AVKit'
  s.dependency 'IQKeyboardManagerSwift'
  #s.dependency 'Firebase/Core'
  #s.dependency 'Firebase/Database'
  s.dependency 'lottie-ios'
  s.dependency 'Kingfisher'

  s.swift_version = "4.2"
end
