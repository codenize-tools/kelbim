require 'aws-sdk'

proc {
  define_client_method = proc do |operation|
    operation[:outputs] ||= {}
    builder = AWS::Core::QueryRequestBuilder.new('2012-06-01', operation)
    parser = AWS::Core::QueryResponseParser.new(operation[:outputs])
    AWS::ELB::Client::V20120601.send(:define_client_method, operation[:method], builder, parser)
  end

  define_client_method.call({
    :name    => 'DescribeLoadBalancerAttributes',
    :method  => :describe_load_balancer_attributes,
    :inputs  => {'LoadBalancerName' => [:string, :required]},
  })

  define_client_method.call({
    :name    => 'ModifyLoadBalancerAttributes',
    :method  => :modify_load_balancer_attributes,
    :inputs  => {
      'LoadBalancerAttributes' => [{
        :structure => {
          'CrossZoneLoadBalancing' => [{
            :structure => {'Enabled' => [:boolean]}
          }]
        }
      }, :required]
    },
  })
}.call
