# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target ‘Budget’ do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  
  pod 'FacebookCore'
  pod 'FacebookLogin'
  
  pod 'Fabric', '~> 1.7.2'
  pod 'Crashlytics', '~> 3.9.3'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if ['FacebookCore', 'FacebookLogin'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
    end
end
