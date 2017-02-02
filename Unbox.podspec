Pod::Spec.new do |s|
  s.name         = "Unbox"
  s.version      = "2.3.1"
  s.summary      = "The easy to use Swift JSON decoder."
  s.description  = <<-DESC
    Unbox is an easy to use Swift JSON decoder. Don't spend hours writing JSON decoding code - just unbox it instead!

    Unbox is lightweight, non-magical and doesn't require you to subclass, make your JSON conform to a specific schema or completely change the way you write model code. It can be used on any model with ease.
  DESC
  s.homepage     = "https://github.com/JohnSundell/Unbox"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "John Sundell" => "john@sundell.co" }
  s.social_media_url   = "https://twitter.com/johnsundell"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/JohnSundell/Unbox.git", :tag => s.version.to_s }
  s.source_files  = "Sources/Unbox.swift"
  s.frameworks  = "Foundation", "CoreGraphics"
end
