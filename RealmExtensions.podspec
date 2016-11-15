Pod::Spec.new do |lib|
  lib.name             = 'RealmExtensions'
  lib.version          = '1.0.1'
  lib.summary          = 'Extensions for Realm Cocoa framework'

  lib.description      = <<-DESC
Modified Realm+JSON library
                       DESC

  lib.homepage         = 'https://github.com/pasha010/realm-cocoa-extensions'
  lib.license          = { :type => 'MIT', :file => 'LICENSE' }
  lib.author           = { 'Pavel Malkov' => 'mpa026@gmail.com' }
  lib.source           = { :git => 'https://github.com/pasha010/realm-cocoa-extensions', :tag => lib.version.to_s }

  lib.ios.deployment_target = '7.0'

  lib.source_files = 'RealmExtensions/*.{h,m}'

  lib.module_map = 'RealmExtensions/RealmExtensions.modulemap'

  lib.dependency 'Realm', '~> 2.0'

end
