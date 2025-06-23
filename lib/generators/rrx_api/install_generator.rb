# frozen_string_literal: true
# frozen_string_literal: true
require_relative 'base'

module RrxApi
  module Generators
    class InstallGenerator < Base
      init! 'Installs the RRX API gem and its dependencies.'

      class_option :skip_rrx_dev, type: :boolean, default: false, hide: true

      # Updates the application configuration file with specific dependencies and settings.
      # The method performs the following operations:
      # - Reads the application configuration file located at 'config/application.rb'.
      # - Removes existing comments and unnecessary `require` statements from the file.
      # - Includes necessary `require` directives for the application's gem dependencies.
      # - Injects or updates the Bundler require statement to include the necessary gems.
      # - Cleans up unwanted whitespace in the file content.
      # - Rewrites the configuration file with the updated content.
      # - Appends additional configuration settings for time zone, schema format, and session management.
      #
      # @return [void] Since the primary purpose is file modification, it does not return a value directly.
      def update_application
        # @type [Pathname]
        app_file = Pathname(destination_root).join('config', 'application.rb')
        app_code = app_file.read

        # Assume full replace if we've never modified before.
        # Otherwise, create_file will prompt to replace it.
        remove_file app_file unless app_code =~ /rrx_api/

        app_code.gsub!(/^\s*#.*\r?\n/, '')
        app_code.gsub!(/^(?:#\s+)?require ["'].*\r?\n/, '')

        requires = application_gems.map do |gem|
          "require '#{gem}'"
        end.join("\n")

        app_code.sub!(/^(Bundler.require.*)$/) do |str|
          <<~REQ
            #{requires}

            #{str}
          REQ
        end

        # Remove existing application config lines
        APPLICATION_CONFIG.each do |line|
          app_code.gsub!(/^\s*#{line}\W*.*\n/, '')
        end

        # Remove unnecessary whitespace
        app_code.lstrip!
        app_code.gsub!(/^\s*\r?\n(\s*\r?\n)+/, "\n")

        # puts app_code
        create_file app_file, app_code
      end

      def update_base_classes
        gsub_file 'app/models/application_record.rb',
                  /ApplicationRecord.*/,
                  'ApplicationRecord < RrxApi::Record'

        gsub_file 'app/controllers/application_controller.rb',
                  /ApplicationController.*/,
                  'ApplicationController < RrxApi::Controller'
      end

      def routes
        inject_into_file 'config/routes.rb',
                         after: "Rails.application.routes.draw do\n" do
          <<~RUBY
            mount RrxApi::Engine => '/'
          RUBY
        end
      end

      def rrx_dev
        generate 'rrx_dev:install' unless options[:skip_rrx_dev]
      end

      def asdf_versions
        create_file '.tool-versions', <<~VERSIONS
          ruby #{ruby_version}
        VERSIONS
      end

      private

      # Configs to remove from the application.rb file
      APPLICATION_CONFIG = <<~CONFIG.split("\n").map(&:strip).freeze
        config.time_zone
        config.active_support.to_time_preserves_timezone
        config.active_record.schema_format
        config.session_store
        config.middleware.use ActionDispatch::Cookies
        config.middleware.use ActionDispatch::Session::CookieStore
      CONFIG

      # @return [Array<String>] The list of application gem names that are dependencies
      def application_gems
        gems = %w[rrx_api]
        gems.concat(%w[rrx_jobs active_job].select { |name| gem?(name) })
      end

      # @param [String] name
      # @return [Boolean] True if gem is a dependency
      def gem?(name)
        bundle_gems.include?(name)
      end

      # @return [Set<String>]
      def bundle_gems
        @bundle_gems ||= bundle.dependencies.map(&:name).to_set
      end

    end
  end
end
