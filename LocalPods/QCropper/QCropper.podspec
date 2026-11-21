# Vendored copy of QCropper 0.1.7 (MIT, https://github.com/qchenqizhi/QCropper),
# patched for resizable windows (iPhone Duo): display scale from trait collections,
# asymmetric safe-area insets on the bars, and crop state kept across window resizes.
Pod::Spec.new do |s|
  s.name             = 'QCropper'
  s.version          = '0.1.7'
  s.summary          = 'Image cropping/rotating/straightening library for iOS in Swift.'
  s.homepage         = 'https://github.com/qchenqizhi/QCropper'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Chen' => 'qchenqizhi@gmail.com' }
  s.source           = { :git => 'https://github.com/qchenqizhi/QCropper.git', :tag => s.version.to_s }
  s.platform         = :ios, '17.6'
  s.swift_version    = '5.0'
  s.source_files     = 'QCropper/**/*'
  s.resources        = ['Assets/*.png']
  s.frameworks       = 'UIKit'
end
