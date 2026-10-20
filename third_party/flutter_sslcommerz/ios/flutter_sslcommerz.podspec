#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_sslcommerz.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_sslcommerz'
  s.version          = '3.0.0'
  s.summary          = 'SSLCommerz is the largest payment gateway of Bangladesh.'
  s.description      = <<-DESC
  This is the official SSLCommerz flutter plugin for Flutter application integration.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'SSL Wireless' => 'abu.sayed@sslwireless.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'SSLCommerzSDK'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  # s.preserve_paths = 'SSLCommerzSDK.xcframework'
  # s.vendored_frameworks = 'SSLCommerzSDK.xcframework'
end
