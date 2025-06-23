# frozen_string_literal: true

my_healthcheck = lambda do
  if params.include?(:fail)
    puts "Healthcheck failed! #{params[:fail]}"
    raise ArgumentError, 'THIS IS A TEST FAILURE'
  else
    puts 'Healthcheck passed!'
  end
end

Rails.application.configure do |app|
  app.config.healthcheck = my_healthcheck
  app.config.healthcheck_route = 'my_healthcheck'
end
