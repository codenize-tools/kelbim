module Kelbim
  class DSL
    module Checker
      private
      def required(name, value)
        invalid = false

        if value
          case value
          when String
            invalid = value.strip.empty?
          when Array, Hash
            invalid = value.empty?
          end
        else
          invalid = true
        end

        raise __identify("`#{name}` is required") if invalid
      end

      def expected_type(value, *types)
        unless types.any? {|t| value.kind_of?(t) }
          raise __identify("Invalid type: #{value}")
        end
      end

      def expected_length(value, length)
        if value.length != length
          raise __identify("Invalid length: #{value}")
        end
      end

      def expected_value(value, *list)
        unless list.any? {|i| value == i }
          raise __identify("Invalid value: #{value}")
        end
      end

      def not_include(value, list)
        if list.include?(value)
          raise __identify("`#{value}` is already included")
        end
      end

      def call_once(method_name)
        @called ||= []

        if @called.include?(method_name)
          raise __identify("`#{method_name}` is already defined")
        end

        @called << method_name
      end

      def __identify(errmsg)
        if @error_identifier
          errmsg = "#{@error_identifier}: #{errmsg}"
        end

        return errmsg
      end
    end # Checker
  end # DSL
end # Kelbim
