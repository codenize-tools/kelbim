module Kelbim
  class Utils
    module Helper
      def matched_elb?(name)
        result = true

        if @options[:exclude_elb_names]
          result &&= @options[:exclude_elb_names].any? {|i| i =~ name }
        end

        if @options[:elb_names]
          result &&= @options[:elb_names].any? {|i| i =~ name }
        end

        result
      end
    end # of class methods
  end
end
