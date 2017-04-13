Pod::Spec.new do |s|
  s.name         = "Cenarius"
  s.version      = "3.0.0"
  s.summary      = "Mobile Hybrid Framework Cenarius iOS Container."
  s.homepage     = "https://github.com/macula-projects/cenarius-ios"
  s.license      = "MIT"
  s.author       = { "M" => "myeveryheart@qq.com" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/macula-projects/cenarius-ios.git", :tag => "#{s.version}" }
  s.source_files = 'Cenarius/**/*.{swift,h,m}'
  s.dependency "Alamofire"
  s.dependency "Alamofire-Synchronous"
  s.dependency "Kingfisher"
  s.dependency 'SwiftyJSON'
  s.dependency 'HandyJSON'
  s.dependency 'NVActivityIndicatorView'
  s.dependency 'Charts'
  s.dependency 'XCGLogger'
  s.dependency 'AsyncSwift'
  s.dependency 'PermissionScope'
  s.dependency 'RealmSwift'
  s.dependency 'SwiftyVersion'
  s.dependency 'Zip'
  s.dependency 'CryptoSwift'
  s.dependency 'WeexSDK'
  s.requires_arc = true
  s.pod_target_xcconfig = {
        'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/WeexSDK',
        'OTHER_LDFLAGS'          => '$(inherited) -undefined dynamic_lookup'
    }
end
