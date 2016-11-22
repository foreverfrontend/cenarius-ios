Pod::Spec.new do |s|
  s.name         = "Cenarius"
  s.version      = "0.4.0"
  s.summary      = "Mobile Hybrid Framework Cenarius iOS Container."
  s.homepage     = "https://github.com/macula-projects/cenarius-ios"
  s.license      = "MIT"
  s.author             = { "M" => "myeveryheart@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/macula-projects/cenarius-ios.git", :tag => "#{s.version}" }
  s.source_files  = "Cenarius.{h,m}","Cenarius/**/*.{h,m}","Cenarius/**/**/*.{h,m}","Cenarius/**/**/**/*.{h,m}","Cenarius/**/**/**/**/*.{h,m}","Cenarius/**/**/**/**/**/*.{h,m}"
  s.frameworks  = "Foundation","UIKit"
  s.dependency "AFNetworking"
  s.requires_arc = true
end
