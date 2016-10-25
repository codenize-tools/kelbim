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
    end # Helper

    class << self
      def diff(obj1, obj2, options = {})
        diffy = Diffy::Diff.new(
          obj1.pretty_inspect,
          obj2.pretty_inspect,
          :diff => '-u'
        )

        out = diffy.to_s(options[:color] ? :color : :text).gsub(/\s+\z/m, '')
        out.gsub!(/^/, options[:indent]) if options[:indent]
        out
      end
    end # of class methods
  end
end
