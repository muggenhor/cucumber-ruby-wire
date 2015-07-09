require 'cucumber/wire/connections'

module Cucumber
  module Wire
    class Installer
      attr_reader :config
      private :config

      def initialize(config)
        @config = config
      end

      def call
        connections = Connections.new(wire_files.map { |wire_file| create_connection(wire_file) })
        config.filters << Filters::ActivateSteps.new(connections)
        config.register_snippet_generator Snippet::Generator.new(connections)
      end

      def create_connection(wire_file)
        Connection.new(Configuration.from_file(wire_file))
      end

      def wire_files
        # TODO: change Cucumber's config object to allow us to get this information
        config.send(:require_dirs).map { |dir| Dir.glob("#{dir}/**/*.wire") }.flatten
      end
    end
  end
end

AfterConfiguration do |config|
  Cucumber::Wire::Installer.new(config).call
end
