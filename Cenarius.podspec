Pod::Spec.new do |s|
  s.name         = "Cenarius"
  s.version      = "3.0.2"
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
  s.dependency 'XCGLogger'
  s.dependency 'AsyncSwift'
  s.dependency 'RealmSwift'
  s.dependency 'SwiftyVersion'
  s.dependency 'Zip'
  s.dependency 'CryptoSwift'
  s.dependency 'SnapKit'
  s.dependency 'Toaster'
  s.dependency 'RTRootNavigationController'
  s.dependency 'SVProgressHUD'
  s.dependency 'WeexSDK', '0.15.0-dynamic'
  s.requires_arc = true
  
end
