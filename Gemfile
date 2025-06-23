# frozen_string_literal: true

source "https://rubygems.org"
gemspec

PARENT_FOLDER = Pathname(__FILE__).parent.parent
gem 'rrx_dev', path: PARENT_FOLDER.join('rrx_dev') if PARENT_FOLDER.join('rrx_dev').exist?
gem 'rrx_logging', path: PARENT_FOLDER.join('rrx_logging') if PARENT_FOLDER.join('rrx_logging').exist?
