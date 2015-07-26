require 'aws-sdk-v1'
require 'fileutils'

AWS.config({
  :access_key_id => (ENV['TEST_AWS_ACCESS_KEY_ID'] || 'scott'),
  :secret_access_key => (ENV['TEST_AWS_SECRET_ACCESS_KEY'] || 'tiger'),
  :region => ENV['TEST_AWS_REGION'],
})

def elbfile(options = {})
  updated = false
  tempfile = `mktemp /tmp/#{File.basename(__FILE__)}.XXXXXX`.strip

  begin
    open(tempfile, 'wb') {|f| f.puts(yield) }
    options = {:logger => Logger.new('/dev/null')}.merge(options)

    if options[:debug]
      AWS.config({
        :http_wire_trace => true,
        :logger => (options[:logger] || Kelbim::Logger.instance),
      })
    end

    mode = options.delete(:mode)
    client = Kelbim::Client.new(options)

    case mode
    when :test
      client.test(tempfile)
      updated = nil
    when :show_load_balancers
      updated = client.load_balancers
    when :show_policies
      updated = client.policies
    else
      updated = client.apply(tempfile)
    end
  ensure
    FileUtils.rm_f(tempfile)
  end

  return updated
end

def export_elb(options = {})
  options = {:logger => Logger.new('/dev/null')}.merge(options)

  if options[:debug]
    AWS.config({
      :http_wire_trace => true,
      :logger => (options[:logger] || Kelbim::Logger.instance),
    })
  end

  client = Kelbim::Client.new(options)
  exported = client.export {|e, c| e }

  exported.each do |vpc, elbs|
    elbs.each do |name, attrs|
      attrs[:instances].sort!
      attrs[:dns_name].sub!(
        /\d+\.us-west-1\.elb\.amazonaws\.com/,
        'NNNNNNNNNN.us-west-1.elb.amazonaws.com')

      attrs[:listeners].each do |listener|
        if (sc = listener[:server_certificate])
          listener[:server_certificate] = sc.name
        end

        listener[:policies].each do |policy|
          policy[:name].sub!(
            /\w+-\w+-\w+-\w+-\w+\Z/,
            'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX')
        end

        listener[:policies] = listener[:policies].sort_by {|i| i[:name] }
      end

      attrs[:listeners] = attrs[:listeners].sort_by do |listener|
        listener.values_at(:protocol, :port, :instance_protocol, :instance_port).join
      end

      if vpc
        attrs[:subnets].sort!
        attrs[:security_groups].sort!
      else
        attrs[:availability_zones].sort!
      end
    end
  end

  return exported
end

def with_elb
  elb = AWS::ELB.new
  AWS.memoize { yield(elb) }
end

def get_policy_names(elb, name)
  lb = elb.load_balancers[name]
  lb.policies.map {|policy|
    policy.name.sub!(/\w+-\w+-\w+-\w+-\w+\Z/, 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX')
  }.sort_by {|i| i || '' }
end
