# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'itagone' do
  platform :ios, '12.4'
  use_frameworks!
  project 'itagone.xcodeproj'

  pod 'Rasat', :git => 'https://github.com/s4ysolutions/Rasat.git'
  pod 'WayTodaySDK', :git => 'https://github.com/s4ysolutions/WayTodaySDK-iOS.git'

  target 'itagoneTests' do
    inherit! :complete
    use_frameworks!
  end

  target 'itagoneUITests' do
    inherit! :complete
    use_frameworks!
  end

  target 'BLE' do
    inherit! :complete
    use_frameworks!
  end

  target 'BLETests' do
    inherit! :complete
    use_frameworks!
  end

end
