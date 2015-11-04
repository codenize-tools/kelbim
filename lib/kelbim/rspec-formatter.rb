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

    def dump_pending
      unless pending_examples.empty?
        output.puts
        output.puts "Pending:"
        pending_examples.each do |pending_example|
          output.puts pending_color("  #{pending_example.full_description}")
          output.puts detail_color("    # #{pending_example.execution_result[:pending_message]}")
        end
      end
    end
  end # RSpecFormatter
end # Kelbim
