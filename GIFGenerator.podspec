#
# Be sure to run `pod lib lint GIFGenerator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "GIFGenerator"
  s.version          = "0.1.1"
  s.summary          = "Generate animated GIF in iOS"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                        Generates a GIF file and saves it to an specific URL
                        - Set frame delays
                        - Set loop count
                       DESC

  s.homepage         = "https://github.com/eduardourso/GIFGenerator"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Eduardo Urso" => "eduardourso@gmail.com" }
  s.source           = { :git => "https://github.com/eduardourso/GIFGenerator.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/DuUrso'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'GIFGenerator' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'ImageIO', 'MobileCoreServices'
  # s.dependency 'AFNetworking', '~> 2.3'
end
