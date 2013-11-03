require 'rspec'
require 'rspec/core/formatters/base_text_formatter'

module RSpec
  module Core
    module Formatters
      class BaseTextFormatter < BaseFormatter
        def dump_failure_info(example)
          exception = example.execution_result[:exception]

          if exception.message
            line = exception.message.to_s.split("\n").first
            line.sub!(/\s*with backtrace:\s*/, '')
            output.puts "#{long_padding}#{failure_color(line)}"
          end
        end

        def dump_backtrace(example)
        end

        def dump_commands_to_rerun_failed_examples
        end
      end # BaseTextFormatter
    end # Formatters
  end # Core
end # RSpec
