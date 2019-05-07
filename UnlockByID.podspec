Pod::Spec.new do |spec|
  spec.name         = 'UnlockByID'
  spec.version      = '1.0.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/keassze/UnlockByID.git'
  spec.authors      = { 'Songze He' => 'keassze@163.com' }
  spec.summary      = '用于面部、指纹解锁的封装类'
  spec.source       = { :git => 'https://github.com/keassze/UnlockByID.git', :tag => spec.version.to_s }
  spec.source_files = 'Sources/Classes/**'
  # 依赖的第三方框架
  # spec.framework    = 'SystemConfiguration'
end