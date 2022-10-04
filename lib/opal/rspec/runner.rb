require 'shellwords'
require 'opal/rspec'
require 'tempfile'
require 'socket'
require 'opal/cli_options'
require 'opal/cli'
require 'opal/rspec/locator'

module Opal
  module RSpec
    class Runner
      attr_accessor :pattern, :requires, :exclude_pattern, :files, :default_path, :runner, :arity_checking, :spec_opts, :cli_options

      def timeout= _
        warn "deprecated: setting timeout has no effect"
      end

      def arity_checking?
        setting = @arity_checking || :enabled
        setting == :enabled
      end

      def source_location?
        :enabled
      end

      def file_source_embed?
        :enabled
      end

      def runner
        (@runner ||= ENV['RUNNER']).to_s
      end

      def requires
        @requires ||= []
      end

      def spec_opts
        @spec_opts ||= ENV['SPEC_OPTS']
      end

      def get_load_asset_code(server)
        sprockets = server.sprockets
        name = server.main
        asset = sprockets[name]
        raise "Cannot find asset: #{name}" if asset.nil?
        # Opal::Sprockets.load_asset name, sprockets
        ''
      end

      class LegacyServerProxy
        require 'set'
        def initialize
          @paths ||= Set.new
        end

        def append_path(path)
          @paths << path
        end

        def index_path=path
          @index_path = path
        end
        attr_reader :index_path

        # noop options
        attr_accessor :debug

        def to_cli_options
          options = []
          @paths.map do |path|
            options << "-I#{path.shellescape}"
          end
          options
        end
      end

      def initialize(&block)
        @legacy_server_proxy = LegacyServerProxy.new
        block.call(@legacy_server_proxy, self) if block_given? # for compatibility

        raise 'Cannot supply both a pattern and files!' if self.files and self.pattern

        locator = ::Opal::RSpec::Locator.new pattern: self.pattern, exclude_pattern: self.exclude_pattern, files: self.files, default_path: self.default_path

        options = []
        options << '--arity-check' if arity_checking?
        options << '--enable-source-location' if source_location?
        options << '--enable-file-source-embed' if file_source_embed?
        options += ['--runner', runner] unless runner.empty?
        options << '-ropal-rspec'
        options << '--missing-require=ignore'
        options += @legacy_server_proxy.to_cli_options

        Opal.paths.each                     { |p| options << "-I#{p}" }
        locator.get_spec_load_paths.each    { |p| options << "-I#{p}" }
        requires.each                       { |p| options << "-r#{p}" }
        locator.get_opal_spec_requires.each { |p| options << "-r#{p}" }
        ::Opal::Config.stubbed_files.each   { |p| options << "-s#{p}" }

        options += @cli_options if @cli_options
        bootstrap_code = [
          ::Opal::RSpec.spec_opts_code(spec_opts),
          '::RSpec::Core::Runner.autorun',
        ].join(';')

        @args = "#{options.map(&:shellescape).join ' '} -e #{bootstrap_code.shellescape}"
      end

      def options
        {
          pattern: pattern,
          exclude_pattern: exclude_pattern,
          files: files,
          default_path: default_path,
          runner: runner,
          arity_checking: arity_checking,
          spec_opts: spec_opts,
        }
      end

      def command
        @command ||= "opal #{@args}"
      end

      def cli_options
        @cli_options ||= begin
          option_parser = Opal::CLIOptions.new
          option_parser.parse!(@args.shellsplit)
          option_parser.options
        end
      end

      def cli
        @cli ||= ::Opal::CLI.new(cli_options)
      end

      def run
        ENV['OPAL_CLI_RUNNERS_SERVER_STATIC_FOLDER'] = default_path
        cli.run
      end
    end
  end
end

