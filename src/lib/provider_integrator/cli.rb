# frozen_string_literal: true

require "optparse"

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

      output.puts "Parsing specification: #{options.fetch(:spec)}"
      output.flush
      path = ProviderIntegrator.generate(
        options.fetch(:spec),
        output_dir: options.fetch(:output_dir)
      )
      output.puts "Generated: #{path}"
      0
    rescue OptionParser::ParseError, KeyError, ArgumentError => exception
      error.puts "Error: #{exception.message}"
      error.puts parser
      64
    rescue Parsers::Error, Extractors::AuthenticationExtractor::UnsupportedAuthenticationError => exception
      error.puts "Generation failed: #{exception.message}"
      1
    rescue SystemCallError => exception
      error.puts "Generation failed: #{exception.message}"
      1
    end

    private

    attr_reader :arguments, :output, :error

    def parse_options
      @options = { output_dir: "output" }
      parser.parse!(arguments)
      raise OptionParser::MissingArgument, "--spec" unless @options[:spec] || @options[:help]
      raise OptionParser::InvalidArgument, arguments.join(" ") unless arguments.empty?

      @options
    end

    def parser
      @parser ||= OptionParser.new do |options|
        options.banner = "Usage: ./integrate --spec PATH [options]"
        options.on("--spec PATH", "Path to an OpenAPI specification") do |path|
          @options[:spec] = path
        end
        options.on("-o DIR", "--output DIR", "Output directory (default: output)") do |directory|
          @options[:output_dir] = directory
        end
        options.on("-h", "--help", "Show this help") do
          output.puts options
          @options[:help] = true
        end
      end
    end
  end
end
