# frozen_string_literal: true

require "optparse"
require "json"

module ProviderIntegrator
  # Минимальный CLI для запуска генерации из OpenAPI-файла.
  class CLI
    def self.start(arguments, output: $stdout, error: $stderr)
      new(arguments, output: output, error: error).run
    end

    def initialize(arguments, output:, error:)
      @arguments = arguments
      @output = output
      @error = error
    end

    def run
      options = parse_options

      return 0 if options[:help]
      return dump_model(options.fetch(:spec)) if options[:dump_model]

      output.puts "Parsing specification: #{options.fetch(:spec)}"
      output.flush

      integration = nil
      paths = ProviderIntegrator.generate(
        options.fetch(:spec),
        output_dir: options.fetch(:output_dir)
      ) do |built_integration|
        integration = built_integration
      end

      paths.each { |path| output.puts "Generated: #{path}" }
      print_diagnostics(integration.diagnostics) if integration

      0
    rescue OptionParser::ParseError, KeyError, ArgumentError => exception
      error.puts "Error: #{exception.message}"
      error.puts parser
      64
    rescue Parsers::Error,
           Extractors::AuthenticationExtractor::UnsupportedAuthenticationError => exception
      error.puts exception.message
      1
    rescue StandardError => exception
      error.puts "#{exception.class}: #{exception.message}"
      error.puts exception.backtrace.first(10)
      1
    end

    private

    attr_reader :arguments, :output, :error

    def print_diagnostics(diagnostics)
      return if diagnostics.empty?

      output.puts "Diagnostics:"
      diagnostics.each do |diagnostic|
        output.puts "  [#{diagnostic.severity}] #{diagnostic.code}: #{diagnostic.message}"
      end
    end

    def dump_model(spec_path)
      output.puts "Parsing specification: #{spec_path}"
      output.flush

      integration = ProviderIntegrator.build(spec_path)
      output.puts JSON.pretty_generate(integration.to_h)

      0
    rescue Parsers::Error => exception
      error.puts exception.message
      1
    end

    def parse_options
      @options = { output_dir: "output" }

      parser.parse!(arguments)

      unless @options[:spec] || @options[:help]
        raise OptionParser::MissingArgument, "--spec"
      end

      unless arguments.empty?
        raise OptionParser::InvalidArgument, arguments.join(" ")
      end

      @options
    end

    def parser
      @parser ||= OptionParser.new do |options|
        options.banner = "Usage: ./integrate --spec PATH [options]"

        options.on("--spec PATH", "Path to an OpenAPI specification") do |path|
          @options[:spec] = path
        end

        options.on(
          "-o DIR",
          "--output DIR",
          "Output directory (default: output)"
        ) do |directory|
          @options[:output_dir] = directory
        end

        options.on(
          "--dump-model",
          "Print Integration Model as JSON without generating files"
        ) do
          @options[:dump_model] = true
        end

        options.on("-h", "--help", "Show this help") do
          output.puts options
          @options[:help] = true
        end
      end
    end
  end
end
