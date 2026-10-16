platform :ios, '15.0'

install! 'cocoapods', :disable_input_output_paths => true

ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'App.xcodeproj'

# flutter 是独立 Git 仓库，以子模块放在宿主内。Android 工程引用同一仓库。
flutter_application_path = 'flutter'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

target 'App' do
  use_frameworks!
  use_modular_headers!

  pod 'SnapKit', :path => 'Vendor/SnapKit'

  install_all_flutter_pods(flutter_application_path)
end

post_install do |installer|
  flutter_post_install(installer)
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
    end
  end
end
