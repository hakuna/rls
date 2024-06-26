# frozen_string_literal: true

require_relative "lib/rls/version"

Gem::Specification.new do |spec|
  spec.name = "rls"
  spec.version = RLS::VERSION
  spec.authors = ["Steven Schmid"]
  spec.email = ["steven@hakuna.ch"]

  spec.summary = "Multi-tenancy using PostgreSQL row level security."
  spec.description = ""
  spec.homepage = "https://www.hakuna.team"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "pg", "~> 1.2"
  spec.add_dependency "rails", ">= 7.0"

  spec.add_development_dependency "appraisal", "~> 2.4"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec-rails", "~> 6.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "rubocop-rails", "~> 2.16"
  spec.add_development_dependency "rubocop-rspec", "~> 2.13"
end
