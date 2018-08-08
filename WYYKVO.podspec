#
# Be sure to run `pod lib lint WYYKVO.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WYYKVO'
  s.version          = '0.1.0'
  s.summary          = 'A custom kvo for ios'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

#s.homepage         = 'https://github.com/youyouwang/WYYKVO/tree/v0.1.0'
s.homepage         = 'https://github.com/youyouwang/WYYKVO'

  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wangyaoyao' => 'wangyaoyao@163.com' }
  
  
  #s.source           = { :git => 'https://github.com/youyouwang/WYYKVO.git', :commit => "68defea" }
  s.source           = { :git => 'https://github.com/youyouwang/WYYKVO.git', :tag => s.version }

#s.source           = { :git => 'https://github.com/youyouwang/WYYKVO.git', :tag => 'v0.1.0' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'WYYKVO/Classes/**/*'
  
  # s.resource_bundles = {
  #   'WYYKVO' => ['WYYKVO/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
