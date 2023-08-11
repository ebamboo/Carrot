platform :ios, '11.0'
inhibit_all_warnings!

target 'Carrot' do
  use_frameworks!

  pod 'Alamofire'
  pod 'KakaJSON'
  pod 'SDWebImage'
  pod 'BBPlayerView'
  pod 'MBProgressHUD'

end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      end
    end
  end
end
