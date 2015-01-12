Pod::Spec.new do |s|
  s.name         = "Bumblebee"
  s.version      = "0.9.1"
  s.summary      = "Abstract text processing and pattern matching engine in Swift. Converts text into NSAttributedStrings. Builtin markdown support."
  s.homepage     = "https://github.com/daltoniam/bumblebee"
  s.license      = 'Apache License, Version 2.0'
  s.author       = {'Dalton Cherry' => 'http://daltoniam.com'}
  s.source       = { :git => 'https://github.com/daltoniam/bumblebee.git',  :tag => '0.9.1'}
  s.platform     = :ios, 8.0
  s.source_files = '*.{h,swift}'
end
