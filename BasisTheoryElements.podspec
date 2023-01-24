Pod::Spec.new do |s|
  s.name = 'BasisTheoryElements'
  s.ios.deployment_target = '14.0'
  s.version = '1.8.1'
  s.source = { :git => 'https://github.com/Basis-Theory/basistheory-ios.git', :tag => '1.8.1' }
  s.authors = 'BasisTheory'
  s.license = 'Apache'
  s.homepage = 'https://github.com/Basis-Theory/basistheory-ios'
  s.summary = 'BasisTheory SDK for Elements'
  s.source_files = 'BasisTheoryElements/Sources/BasisTheoryElements**/*.swift'
  s.dependency 'BasisTheory', '0.6.0'
  s.swift_version = '5.5'
end
