Pod::Spec.new do |s|
  s.name         = "Bumblebee"
  s.version      = "2.1.0"
  s.summary      = "Abstract text processing and pattern matching engine in Swift. Converts text into NSAttributedStrings. Builtin markdown support."
  s.homepage     = "https://github.com/daltoniam/bumblebee"
  s.license      = 'Apache License, Version 2.0'
  s.author       = {'Dalton Cherry' => 'http://daltoniam.com'}
  s.source       = { :git => 'https://github.com/daltoniam/bumblebee.git',  :tag => "#{s.version}"}
  s.social_media_url = 'http://twitter.com/daltoniam'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.source_files = 'Sources/*.swift'
end
