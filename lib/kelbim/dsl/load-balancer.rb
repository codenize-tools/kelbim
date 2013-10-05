require 'ostruct'
require 'piculet/dsl/permissions'

module Kelbim
  class DSL
    class EC2
      class LoadBalancer
        def initialize(name, vpc, &block)
          @name = name
          @vpc = vpc

          @result = OpenStruct.new({
            :name => name,
          })
        end

        def result
          @result
        end
      end # LoadBalancer
    end # EC2
  end # DSL
end # Kelbim
