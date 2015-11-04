module Kelbim
  class Utils
    module Helper
      def matched_elb?(name)
        result = true

        if @options[:exclude_elb_name]
          result &&= name !~ @options[:exclude_elb_name]
        end

        if @options[:elb_name]
          result &&= name =~ @options[:elb_name]
        end

        result
      end
    end # of class methods
  end
end
