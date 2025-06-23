# frozen_string_literal: true

require_relative 'base'

module RrxApi
  module Generators
    class DockerGenerator < Base
      init! 'Generates configuration files for building a docker image.'

      class_option :image_name, type: :string, desc: 'Name of the Docker image. Defaults to application name.'

      def docker
        template 'docker/Dockerfile.tt', 'Dockerfile'
      end

      alias image_name app_name
    end
  end
end
