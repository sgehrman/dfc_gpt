#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'dfc_gpt'
  s.version          = '0.0.1'
  s.summary          = 'A macOS implementation of the dfc_gpt plugin.'
  s.description      = <<-DESC
  A macOS implementation of the dfc_gpt plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.vendored_libraries = 'Libraries/**/*'

  # we need this in the main bundle, this seems to put it in the dfc_gpt framework
  # we will copy this file when building the host app
  # s.resources = ['Resources/**/*']

  s.platform = :osx
  s.osx.deployment_target = '11.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end

