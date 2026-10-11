platform :ios, '17.6'

target 'colorful-room' do
  use_frameworks!
  pod 'QCropper'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.6'
    end
  end
end
