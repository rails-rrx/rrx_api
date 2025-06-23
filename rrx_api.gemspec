# frozen_string_literal: true

require_relative 'lib/rrx_api/version'

Gem::Specification.new do |spec|
  source_uri = 'https://github.com/rails-rrx/rrx_api'
  home_uri   = source_uri

  spec.name    = 'rrx_api'
  spec.version = RrxApi::VERSION
  spec.authors = ['Dan Drew']
  spec.email   = ['dan.drew@hotmail.com']

  spec.summary = 'Ruby on Rails core API support'
  # spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage              = home_uri
  spec.license               = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = source_uri
  # spec.metadata["changelog_uri"] = "#{source_uri}..."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end

  # spec.bindir        = 'exe'
  # spec.executables   = %w[rrx_api]
  spec.require_paths = ['lib']

  spec.add_dependency 'actionpack-action_caching'
  spec.add_dependency 'bootsnap'
  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'jbuilder', '~> 2.13'
  spec.add_dependency 'kaminari'
  spec.add_dependency 'puma'
  spec.add_dependency 'rack-cors'
  spec.add_dependency 'rails', RrxApi::RAILS_VERSION
  spec.add_dependency 'rrx_config', RrxApi::DEPENDENCY_VERSION
  spec.add_dependency 'rrx_logging', RrxApi::DEPENDENCY_VERSION
  spec.add_dependency 'rswag-api'
  spec.add_dependency 'rswag-ui'
  spec.add_dependency 'thor'
  spec.add_dependency 'tzinfo-data' # Windows does not include zoneinfo files, so bundle the tzinfo-data gem

  spec.add_development_dependency 'generator_spec'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'rrx_dev', RrxApi::DEPENDENCY_VERSION
end
