Pod::Spec.new do |s|
  s.name = 'Gist'
  s.version = '3.2.0'
  s.summary = 'Gist'
  s.description = 'Gist enables you to create embeddable experiences that range from simple welcome messages to complex multi-step flows.'
  s.homepage = 'https://gist.build'
  s.license = { :type => 'Bourbon Platform License', :file => 'LICENSE' }
  s.author = 'Bourbon Ltd'
  s.swift_version = '5.0'

  s.ios.deployment_target = '10.0'

  s.source = { :git => 'https://github.com/customerio/gist-apple.git', :tag => s.version }

  s.source_files  = 'Gist/*.{swift,h,m}', 'Gist/**/*.{swift,h,m}'
end
