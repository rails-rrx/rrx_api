# frozen_string_literal: true
require_relative 'base'

module RrxApi
  module Generators
    class TerraformGenerator < Base
      init! 'Generates Terraform scripts for deploying the service as a docker container.'

      class_option :cloud,
                   default: 'aws',
                   enum:    %w[aws],
                   desc:    'Cloud provider for deployment (currently only AWS is supported)'

      class_option :bucket,
                   type: :string,
                   desc: 'S3 bucket name for storing Terraform state files (default: store state locally)'

      class_option :key,
                   type: :string,
                   desc: 'S3 key for the Terraform state file (default: app name)'

      class_option :aws_profile,
                   type: :string,
                   desc: 'AWS profile to use for deployment (default: current profile)'

      class_option :aws_region,
                   type:    :string,
                   default: 'us-west-2',
                   desc:    'AWS region for deployment (default: us-west-2)'

      class_option :ecs_cluster,
                   type: :string,
                   desc: 'ECS cluster name for deployment (default: deployment environment name)'

      class_option :environments,
                   type:    :boolean,
                   default: false,
                   aliases: '-e',
                   desc:    'Generate terraform files that targets multiple environments (default: false)'

      def terraform
        directory "terraform/#{options[:cloud]}", 'terraform'
      end

      private

      def environments?
        options[:environments]
      end

      def terraform_version
        '1.9'
      end

      def s3_bucket
        options[:bucket]
      end

      def s3_key
        options[:key] || app_name
      end

      def aws_profile
        options[:aws_profile]
      end

      def aws_region
        options[:aws_region]
      end

      def ecs_cluster
        options.include?(:ecs_cluster) ? "'#{options[:ecs_cluster]}'" : 'terraform.workspace'
      end
    end
  end
end
