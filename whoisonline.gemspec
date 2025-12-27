require_relative "lib/whoisonline/version"

Gem::Specification.new do |spec|
  spec.name          = "whoisonline"
  spec.version       = WhoIsOnline::VERSION
  spec.authors       = ["Kapil Dev Pal"]
  spec.email         = ["dev.kapildevpal@gmail.com"]
  spec.summary       = "Redis-backed online presence for Rails without database writes"
  spec.description   = "Production-ready Rails 7/8 online presence tracking using Redis TTL and controller auto-hook."
  spec.homepage      = "https://github.com/KapilDevPal/WhoIsOnline"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.1"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.glob("lib/**/*") + %w[README.md logowho.png]
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 7.0"
  spec.add_dependency "railties", "~> 7.0"
  spec.add_dependency "redis", "~> 4.0"
  spec.add_dependency "concurrent-ruby", "~> 1.2"
end


