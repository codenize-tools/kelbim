require 'forwardable'
require 'kelbim/ext/elb-listener-ext'
require 'kelbim/wrapper/policy-collection'
require 'kelbim/logger'

module Kelbim
  class ELBWrapper
    class LoadBalancerCollection
      class LoadBalancer
        class ListenerCollection
          class Listener
            extend Forwardable
            include Logger::ClientHelper

            def_delegators(
              :@listener,
              :protocol, :port, :instance_protocol, :instance_port, :load_balancer)

            def initialize(listener, options)
              @listener = listener
              @options = options
            end

            def policies
              PolicyCollection.new(@listener.policies, self, @options)
            end

            def eql?(dsl)
              not has_difference_protocol_port?(dsl) and compare_server_certificate(dsl)
            end

            def update(dsl)
              log(:info, 'Update Listener', :green, log_id)

              compare_server_certificate(dsl) do
                log(:info, "  set server_certificate=#{dsl.server_certificate}", :green)

                unless @options.dry_run
                  ss = @options.iam.server_certificates[dsl.server_certificate]

                  unless ss
                    raise "Can't find ServerCertificate: #{ss_name} in #{log_id}"
                  end

                  @listener.server_certificate = ss
                  @options.updated = true
                end
              end
            end

            def policies=(policy_list)
              log(:info, 'Update Listener Policies', :green, log_id)
              log(:info, '  set policies=' + policy_list.map {|i| i.name }.join(', '), :green)

              unless @options.dry_run
                @options.elb.client.set_load_balancer_policies_of_listener({
                  :load_balancer_name => @listener.load_balancer.name,
                  :load_balancer_port => @listener.port,
                  :policy_names       => policy_list.map {|i| i.name },
                })

                @options.updated = true
              end
            end

            def delete
              log(:info, 'Delete Listener', :red, log_id)

              related_policies = self.policies

              unless @options.dry_run
                @listener.delete
                @options.updated = true
              end

              unless @options.without_deleting_policy
                related_policies.each do |plcy|
                  plcy.delete
                end
              end
            end

            def has_difference_protocol_port?(dsl)
              not (
                @listener.protocol          == dsl.protocol          &&
                @listener.port              == dsl.port              &&
                @listener.instance_protocol == dsl.instance_protocol &&
                @listener.instance_port     == dsl.instance_port
              )
            end

            def log_id
              log_id = [[@listener.protocol, @listener.port], [@listener.instance_protocol, @listener.instance_port]].map {|i| i.inspect }.join(' => ')
              "#{@listener.load_balancer.vpc_id || :classic} > #{@listener.load_balancer.name} > #{log_id}"
            end

            private
            def compare_server_certificate(dsl)
              aws_server_certificate = @listener.server_certificate
              aws_server_certificate = aws_server_certificate.name if aws_server_certificate
              same = (aws_server_certificate == dsl.server_certificate)
              yield if !same && block_given?
              return same
            end
          end # Listener
        end # ListenerCollection
      end # LoadBalancer
    end # LoadBalancerCollection
  end # ELBWrapper
end # Kelbim
