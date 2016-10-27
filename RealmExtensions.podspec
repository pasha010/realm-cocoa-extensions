Pod::Spec.new do |lib|
  lib.name             = 'RealmExtensions'
  lib.version          = '1.0'
  lib.summary          = 'Extensions for Realm Cocoa framework'

  lib.description      = <<-DESC
Modifed Realm+JSON library
                       DESC

  lib.homepage         = 'https://github.com/pasha010/realm-cocoa-extensions'
  lib.license          = { :type => 'MIT', :file => 'LICENSE' }
  lib.author           = { 'Pavel Malkov' => 'mpa026@gmail.com' }
  lib.source           = { :git => 'https://github.com/pasha010/realm-cocoa-extensions', :tag => lib.version.to_s }

  lib.ios.deployment_target = '7.0'
  lib.osx.deployment_target   = '10.9'
  lib.watchos.deployment_target = '2.0'
  lib.tvos.deployment_target = '9.0'

  lib.source_files = 'RealmExtensions/*'

  lib.module_map = 'RealmExtensions/RealmExtensions.modulemap'

  lib.dependency 'Realm', '~> 2.0'

end
