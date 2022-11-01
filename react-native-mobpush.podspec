# react-native-mobpush.podspec

require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-mobpush"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = package["description"]
  s.homepage     = "https://github.com/github_account/react-native-mobpush"
  # brief license entry:
  s.license      = "MIT"
  # optional - use expanded license entry instead:
#   s.license    = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Your Name" => "yourname@email.com" }
  s.platforms    = { :ios => "8.0" }
  s.source       = { :git => "", :tag => "#{s.version}" }

  s.source_files = "ios/MobPushModule/*.{h,c,cc,cpp,m,mm,swift}"
  s.header_dir = "ios/MobPushModule/*.h"
  s.requires_arc = true
  
  s.dependency "React"
  s.dependency 'mob_pushsdk'
  # 标准: 固定为true
  s.static_framework = true
  
end

