#
# Be sure to run `pod lib lint LUITool.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LUITool'
  s.version          = '0.1.0'
  s.summary          = '基础工具库'
  # 本地测试pod库：pod lib lint --allow-warnings --verbose --no-clean
  # 远程验证:pod spec lint --allow-warnings --verbose --no-clean
  # 推送到xxx私有源：pod repo push xxxspecs MKUI.podspec --allow-warnings --verbose
  # 推到官方源：pod trunk push LUITool.podspec --allow-warnings --verbose

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  * 主题，自定义tabbar，简化tableView，collectionView，自定义alertView，actionSheetView
                       DESC

  s.homepage         = 'https://github.com/linlishu8/LUITool'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'linlishu8' => 'linlishu8@163.com' }
  s.source           = { :git => 'https://github.com/linlishu8/LUITool.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'LUITool/Classes/**/*'
  
  # s.resource_bundles = {
  #   'LUITool' => ['LUITool/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
