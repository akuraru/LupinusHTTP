Pod::Spec.new do |s|
  s.name         = "LupinusHTTP"
  s.version      = "1.0.1"
  s.summary      = "LupinusHTTP is an HTTP networking library, wrapping NSURLSession."
  s.homepage     = "https://github.com/PlusR/LupinusHTTP"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "azu" => "info@efcl.info" }
  s.social_media_url   = "https://twitter.com/azu_re"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/PlusR/LupinusHTTP.git", :tag => s.version.to_s }
  s.source_files  = "Classes/**/*.{h,m}"
  s.requires_arc = true
  s.dependency "NSDictionaryAsURLQuery"
end
