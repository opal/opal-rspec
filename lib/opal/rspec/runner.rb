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
      attr_accessor :runner, :arity_checking, :spec_opts, :cli_options, :files

      # Delegate property changes to spec_opts
      def self.spec_opts_accessor(*names)
        names.each do |name|
          define_method name do
            spec_opts[name]
          end
          define_method :"#{name}=" do |value|
            spec_opts[name] = value
          end
        end
      end

      spec_opts_accessor :libs, :requires, :pattern, :exclude_pattern, :default_path, :files_or_directories_to_run

      alias files files_or_directories_to_run
      alias files= files_or_directories_to_run=

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
        spec_opts[:requires] ||= []
      end

      def spec_opts
        @spec_opts = Opal::RSpec.convert_spec_opts(@spec_opts)
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

        raise 'Cannot supply both a pattern and files!' if self.files \
                                                        && !self.files.empty? \
                                                        && self.pattern

        append_opts_from_config_file

        locator = ::Opal::RSpec::Locator.new pattern: self.pattern,
                                             exclude_pattern: self.exclude_pattern,
                                             files: self.files,
                                             default_path: self.default_path

        options = []
        options << '--arity-check' if arity_checking?
        options << '--enable-source-location' if source_location?
        options << '--enable-file-source-embed' if file_source_embed?
        options += ['--runner', runner] unless runner.empty?
        options << '-ropal-rspec'
        options << '--missing-require=ignore'
        options += @legacy_server_proxy.to_cli_options

        spec_opts.delete(:opal_rbrequires) { [] }.each do |r|
          require r
        end

        load_paths = [Opal.paths, locator.get_spec_load_paths, self.libs].compact.sum([]).uniq

        load_paths.each                     { |p| options << "-I#{p}" }
        requires.each                       { |p| options << "-r#{p}" }
        locator.get_opal_spec_requires.each { |p| options << "-p#{p}" }
        ::Opal::Config.stubbed_files.each   { |p| options << "-s#{p}" }

        options += @cli_options if @cli_options
        options += spec_opts.delete(:opal_options) { [] }

        bootstrap_code = ::Opal::RSpec.spec_opts_code(spec_opts)

        @args = "#{options.map(&:shellescape).join ' '} -e #{bootstrap_code.shellescape}"
      end

      def append_opts_from_config_file
        self.libs ||= []
        self.requires ||= []

        config_location = nil
        path = self.default_path || "spec-opal"

        # Locate config file
        begin
          loop do
            if File.exist?(File.join(path, ".rspec-opal"))
              path = File.join(path, ".rspec-opal")
              break
            else
              new_path = File.expand_path("..", path)
              return if new_path == path
              path = new_path
            end
          end
        rescue e
          # we've gone too far beyond our permissions without finding a config file
          return
        end

        if path
          config_opts = Opal::RSpec.convert_spec_opts(File.read(path))
        else
          return
        end

        self.spec_opts = config_opts.merge(spec_opts) do |key, oldval, newval|
          [:libs, :requires].include?(key) ? oldval + newval : newval
        end
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

