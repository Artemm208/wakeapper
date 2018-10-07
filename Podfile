# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'
inhibit_all_warnings!

target 'Wakeapper' do
  
  use_frameworks!

  pod 'R.swift'
  pod 'RAMAnimatedTabBarController'
  pod 'SwinjectStoryboard'
  pod 'RxSwift', :git => 'https://github.com/ReactiveX/RxSwift.git', :branch => 'develop'
  pod 'RxCocoa', :git => 'https://github.com/ReactiveX/RxSwift.git', :branch => 'develop'
  pod 'Repeat'

  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |configuration|
              configuration.build_settings['SWIFT_VERSION'] = "4.0"
          end
      end
  end
  
  target 'WakeapperTests' do
    inherit! :search_paths
    

  end

end
