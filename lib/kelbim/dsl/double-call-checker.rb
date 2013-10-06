module Kelbim
  class DSL
    module DoubleCallChecker
      def check_called(method_name)
        @called ||= []

        if @called.include?[method_name]
          errmsg = "`#{method_name}` is already defined"
          errmsg = "#{@error_identifier}: #{errmsg}" if @error_identifier
          raise errmsg
        end

        @called << method_name
      end
    end # DoubleCallChecker
  end # DSL
end # Kelbim
