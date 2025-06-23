# RrxApi

Opinionated base library for simplifying development of Rails API projects.

Note that this gem expects the [rrx_dev](https://github.com/rails-rrx/rrx_api/blob/main/CODE_OF_CONDUCT.md) but does
not list it as a dependency as it is only needed for development and tests. Please add it to your Gemfile manually
or as described below with the `bundle add` command.

## Installation

Install the gem and add to the application's Gemfile by executing:

```shell
$ bundle add rrx_dev --group "development, test"
$ bundle add rrx_api
```

If bundler is not being used to manage dependencies, install the gem by executing:

```shell
$ gem install rrx_dev rrx_api
```

After installing, initialize your project with `rrx_api_setup`. Note this will also invoke `rrx_dev_setup app` to
perform development and test setup.

```shell
$ rrx_api
```

## Usage

TODO

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rails-rrx/rrx_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/rails-rrx/rrx_api/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RrxApi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rrx_api/blob/main/CODE_OF_CONDUCT.md).
