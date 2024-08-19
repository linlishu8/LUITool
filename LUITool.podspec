#
# Be sure to run `pod lib lint LUITool.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LUITool'
  s.version          = '0.1.9'
  s.summary          = '基础工具库'
  # 本地测试pod库：pod lib lint --allow-warnings --verbose --no-clean
  # 远程验证:pod spec lint --allow-warnings --verbose --no-clean
  # 推送到xxx私有源：pod repo push xxxspecs LUI.podspec --allow-warnings --verbose
  # 推到官方源：pod trunk push LUITool.podspec --allow-warnings --verbose

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  * 主题，自定义tabbar，简化tableView，collectionView，自定义alertView，actionSheetView, 可扩大点击范围的按钮，有内边距的label，聊天界面，搜索，自定义键盘，
                       DESC

  s.homepage         = 'https://github.com/linlishu8/LUITool'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'linlishu8' => 'linlishu8@163.com' }
  s.source           = { :git => 'https://github.com/linlishu8/LUITool.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'LUITool/Classes/*.h'
  s.frameworks = 'UIKit'
  
  #LUICore基础
  s.subspec 'LUICore' do |ss|
    ss.source_files = 'LUITool/Classes/LUICore/*.{h,m}'
    ss.frameworks = 'UIKit'
  end
  
  #LUICategory扩展
  s.subspec 'LUICategory' do |ss|
    ss.source_files = 'LUITool/Classes/LUICategory/*.{h,m}'
    ss.dependency 'LUITool/LUICore'
    ss.frameworks = 'UIKit'
  end
  
  #布局容器
  s.subspec 'LUIConstraint' do |ss|
    ss.source_files = 'LUITool/Classes/LUIConstraint/*.{h,m}'
    ss.dependency 'LUITool/LUICore'
    ss.frameworks = 'UIKit'
  end
  
  #可扩大点击区域的按钮
  s.subspec 'LUILayoutButton' do |ss|
    ss.source_files = 'LUITool/Classes/LUILayoutButton/*.{h,m}'
    ss.dependency 'LUITool/LUIConstraint'
    ss.dependency 'LUITool/LUICategory'
    ss.dependency 'LUITool/LUICore'
    ss.frameworks = 'UIKit'
  end
  
  #集合基础数据模型
  s.subspec 'LUICollectionModelBase' do |ss|
    ss.source_files = 'LUITool/Classes/LUICollectionModelBase/*.{h,m}'
    ss.dependency 'LUITool/LUICategory'
    ss.dependency 'LUITool/LUICore'
    ss.frameworks = 'UIKit'
  end
  
  #对UITableView进行模型数据封装
  s.subspec 'LUITableView' do |ss|
    ss.source_files = 'LUITool/Classes/LUITableView/*.{h,m}'
    ss.dependency 'LUITool/LUICollectionModelBase'
    ss.dependency 'LUITool/LUIConstraint'
    ss.dependency 'LUITool/LUICategory'
    ss.dependency 'LUITool/LUICore'
    ss.frameworks = 'UIKit'
  end
  
  #对UICollectionView进行模型数据封装
  s.subspec 'LUICollectionView' do |ss|
    ss.source_files = 'LUITool/Classes/LUICollectionView/*.{h,m}'
    ss.dependency 'LUITool/LUICollectionModelBase'
    ss.dependency 'LUITool/LUIConstraint'
    ss.dependency 'LUITool/LUICategory'
    ss.dependency 'LUITool/LUICore'
    ss.frameworks = 'UIKit'
  end
  
  #Theme(主题化)
  s.subspec 'LUITheme' do |ss|
    ss.source_files = 'LUITool/Classes/LUITheme/*.{h,m}'
    ss.dependency 'LUITool/LUICore'
    ss.dependency 'LUITool/LUICategory'
    ss.frameworks = 'UIKit'
  end
  
  #Theme(主题化)
  s.subspec 'LUIEdgeInsetsUILabel' do |ss|
    ss.source_files = 'LUITool/Classes/LUIEdgeInsetsUILabel/*.{h,m}'
    ss.frameworks = 'UIKit'
  end
  
  #CollectionViewLayout(自定义集合布局)
  s.subspec 'LUICollectionViewLayout' do |ss|
    ss.source_files = 'LUITool/Classes/LUICollectionViewLayout/*.{h,m}'
    ss.dependency 'LUITool/LUICore'
    ss.dependency 'LUITool/LUICategory'
    ss.dependency 'LUITool/LUIConstraint'
    ss.frameworks = 'UIKit'
  end
  
  #SafeKeyboard(自定义安全键盘)
  s.subspec 'LUIKeyboard' do |ss|
    ss.source_files = 'LUITool/Classes/LUIKeyboard/*.{h,m}'
    ss.frameworks = 'UIKit'
  end
  
  # s.resource_bundles = {
  #   'LUITool' => ['LUITool/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
