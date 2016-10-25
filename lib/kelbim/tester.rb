module Kelbim
  class Tester
    class << self
      def test(dsl)
        self.new(dsl).test
      end
    end # of class methods

    def initialize(dsl)
      @dsl = dsl
    end

    def test
      require 'rspec/autorun'

      @dsl.ec2s.each do |vpc, ec2|
        vpc ||= 'classic'

        ec2.load_balancers.each do |lb|
          if lb.spec
            RSpec.describe("#{vpc || :classic} > #{lb.name}") {
              it(&lb.spec)
            }
          end
        end
      end
    end
  end # Tester
end # Kelbim
