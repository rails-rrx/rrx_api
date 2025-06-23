# frozen_string_literal: true

require 'generator_spec'
require 'fileutils'
require 'pathname'
require 'generators/rrx_api/install_generator'

GEMFILE = <<~RUBY
  source 'https://rubygems.org'
  ruby '~> 3.1.4'
  gem 'rails'
RUBY

ROUTES_CONFIG = <<~RUBY
  Rails.application.routes.draw do
    get 'blah', to: 'blah#index'
  end
RUBY

APPLICATION_CONFIG = <<~RUBY
  require 'rails'
  # Some comment

  Bundler.require(*Rails.groups)

  module TestApp
    class Application < Rails::Application
      config.time_zone = 'UTC'
      config.something = 'blah'
      config.session_store :cookie_store, key: 'blah_session'
      config.middleware.use Foo::Bar
      config.something_else = 'blah'
    end
  end
RUBY

EXPECTED_APPLICATION_CONFIG = <<~RUBY
  require 'rrx_api'

  Bundler.require(*Rails.groups)

  module TestApp
    class Application < Rails::Application
      config.something = 'blah'
      config.middleware.use Foo::Bar
      config.something_else = 'blah'
    end
  end
RUBY

APPLICATION_CONTROLLER = <<~RUBY
  class ApplicationController < ActionController::Base
  end
RUBY

APPLICATION_RECORD = <<~RUBY
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
RUBY

describe RrxApi::Generators::InstallGenerator, type: :generator do
  destination File.expand_path('../../../tmp/dummy_app', __dir__)
  arguments %w[--skip-rrx-dev]

  let(:destination_path) { Pathname(destination_root).freeze }
  let(:config_path) { destination_path.join('config').freeze }
  let(:application) { destination_path.join('config', 'application.rb').freeze }
  let(:gemfile) { destination_path.join('Gemfile').freeze }
  let(:routes_file) { destination_path.join('config', 'routes.rb').freeze }

  before do
    prepare_destination

    config_path.mkpath
    destination_path.join('app', 'controllers').mkpath
    destination_path.join('app', 'models').mkpath
    destination_path.join('db', 'migrate').mkpath

    routes_file.write ROUTES_CONFIG
    gemfile.write GEMFILE
    application.write APPLICATION_CONFIG
    destination_path.join('app', 'controllers', 'application_controller.rb').write APPLICATION_CONTROLLER
    destination_path.join('app', 'models', 'application_record.rb').write APPLICATION_RECORD

    run_generator
  end

  it 'runs successfully' do
    expect(destination_root).to have_structure {
      directory 'config' do
        file 'routes.rb' do
          contains "mount RrxApi::Engine => '/'\n"
        end
        file 'application.rb'
        directory 'initializers' do
          file 'cors.rb'
          no_file 'generators.rb'
        end
      end

      directory 'docker' do
        file 'Dockerfile' do
          contains 'FROM ddrew555/rrx_docker:3.1'
        end
      end

      directory 'app' do
        directory 'controllers' do
          file 'application_controller.rb' do
            contains 'ApplicationController < RrxApi::Controller'
          end
        end
        directory 'models' do
          file 'application_record.rb' do
            contains 'ApplicationRecord < RrxApi::Record'
          end
        end
      end
    }

    application_content = application.read.strip
    expected_content = EXPECTED_APPLICATION_CONFIG.strip
    expect(application_content).to eq(expected_content)
  end
end
