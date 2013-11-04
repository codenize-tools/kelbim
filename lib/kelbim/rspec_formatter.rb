require 'rspec'
require 'rspec/core/formatters/progress_formatter'

module Kelbim
  class RSpecFormatter < RSpec::Core::Formatters::ProgressFormatter
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
  end # RSpecFormatter
end # Kelbim
