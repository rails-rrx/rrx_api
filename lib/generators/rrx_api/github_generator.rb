# frozen_string_literal: true
require_relative 'base'

module RrxApi
  module Generators
    class GithubGenerator < Base
      init! 'Generates GitHub Actions workflows for building and deploying the application using Docker.'

      class_option :deploy,
                   type:    :boolean,
                   default: false,
                   desc:    'Include deployment workflow'

      class_option :terraform_repo,
                   type:    :string,
                   default: 'terraform',
                   desc:    'Terraform repository name (if using deployment workflow)'

      class_option :terraform_module,
                   type: :string,
                   desc: 'Terraform module name (if using deployment workflow). Default is the application name.'

      class_option :database,
                   type:    :string,
                   default: 'auto',
                   enum:    %w[auto postgresql mysql mariadb sqlite none],
                   desc:    'Database type'

      def github
        directory 'github/build', '.github'
        directory 'github/deploy', '.github' if deploy?
      end

      private

      def deploy?
        options[:deploy]
      end

      def database
        @database ||= options[:database] == 'auto' ? detect_database : options[:database]
      end

      def terraform_repo
        options[:terraform_repo]
      end

      def terraform_module
        options[:terraform_module] || app_name
      end

      def docker_packages
        ''
      end

      def detect_database
        config_path = destination_path.join('config/database.yml')
        if config_path.exist?
          # @type {Hash}
          config  = YAML.safe_load(config_path.read, symbolize_names: true, aliases: true)
          adapter = config.dig(:test, :adapter).to_s.downcase
          case adapter
          when /postgresql/, /psql/
            'postgresql'
          when /mysql/
            if yes?('Detected MySQL adapter in database.yml. Are you using MariaDB? (Yn)')
              'mariadb'
            else
              'mysql'
            end
          when /sqlite/
            'sqlite'
          else
            say_error 'Unsupported database adapter detected in config/database.yml. Please specify the database type explicitly using --database option.'
            exit 1
          end
        else
          'none'
        end
      end
    end
  end
end
