Pod::Spec.new do |s|
  s.name = 'BasisTheoryElements'
  s.ios.deployment_target = '13.0'
  s.version = '4.0.2'
  s.source = { :git => 'https://github.com/Basis-Theory/basistheory-ios.git', :tag => '4.0.2' }
  s.authors = 'BasisTheory'
  s.license = 'Apache'
  s.homepage = 'https://github.com/Basis-Theory/basistheory-ios'
  s.summary = 'BasisTheory SDK for Elements'
  s.source_files = 'BasisTheoryElements/Sources/BasisTheoryElements**/*.swift'
  s.dependency 'BasisTheory', '0.6.1'
  s.swift_version = '5.5'
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'COCOAPODS=1' }
  s.resource_bundles = { 
    'BasisTheoryElements_BasisTheoryElements' => [
      'BasisTheoryElements/Sources/BasisTheoryElements/Resources/Assets.xcassets'
      ] 
  }
end
