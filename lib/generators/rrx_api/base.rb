# frozen_string_literal: true

module RrxApi
  module Generators
    class Base < ::Rails::Generators::Base
      hide!

      def self.init!(description = nil)
        # noinspection RubyMismatchedArgumentType
        source_root Pathname(__dir__).join('templates')
        desc description if description
      end

      protected

      # class Version
      #   def initialize(str)
      #     @version = str.to_s
      #     @segments = @version.split('.').map(&:to_i)
      #   end
      #
      #   def to_s
      #     @version
      #   end
      #
      #   def major
      #     @segments[0]
      #   end
      #
      #   def minor
      #     @segments[1]
      #   end
      #
      #   def build
      #     @segments[2] || 0
      #   end
      #
      #   def major_minor
      #     "#{major}.#{minor}"
      #   end
      #
      #   def <=>(other)
      #     return nil unless other.is_a?(Version)
      #
      #     result = major <=> other.major
      #     result = minor <=> other.minor if result.zero?
      #     result = build <=> other.build if result.zero?
      #     result
      #   end
      # end

      def destination_path
        @destination_path = Pathname(destination_root)
      end

      def app_name
        @app_name ||= destination_path.basename.to_s
      end

      # @return [String] Current Ruby version in format "MAJOR.MINOR"
      def ruby_version
        @ruby_version ||= bundle_max_ruby_version || current_ruby_version
      end

      # @return [Bundler::Definition]
      def bundle
        @bundle ||= Bundler::Definition.build(
          destination_path.join('Gemfile'),
          destination_path.join('Gemfile.lock'),
          nil
        )
      end

      def current_ruby_version
        RUBY_VERSION.split('.')[0..1].join('.')
      end

      def bundle_max_ruby_version
        return nil unless bundle.ruby_version

        version   = Gem::Requirement.new(*bundle.ruby_version.versions)
        max_minor = version
                      .requirements
                      .map { |_, v| v.segments[0..1] } # [major, minor]

        if max_minor.any?
          max_minor.min_by { |major, minor| [major, minor] }.join('.')
        else
          nil
        end

      end
    end
  end
end
