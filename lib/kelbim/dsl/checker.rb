module Kelbim
  class DSL
    module Checker
      private
      def call_once(method_name)
        @called ||= []

        if @called.include?[method_name]
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
