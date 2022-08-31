Pod::Spec.new do |s|
  s.name             = 'AsyncPlus'
  s.version          = '1.0.2'
  s.summary          = 'A simple chainable interface for your async and throwing code, similar to promises and futures.'
  s.homepage         = 'https://asyncplus.codes/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Gabe Montague' => 'github@asyncplus.codes' }
  s.source           = { :git => 'https://github.com/async-plus/async-plus.git', :tag => s.version.to_s }
  s.documentation_url = 'https://docs.asyncplus.codes/'
  s.osx.deployment_target = '10.15'
  s.ios.deployment_target = '13.0'
  s.tvos.deployment_target = '13.0'
  s.watchos.deployment_target = '6.0'
  s.swift_version = '5.5'
  s.source_files = 'Sources/AsyncPlus/**/*'
    s.social_media_url = 'https://twitter.com/async_plus'
end

