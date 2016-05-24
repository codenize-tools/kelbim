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
              :protocol, :port, :instance_protocol, :instance_port, :load_balancer, :ssl_certificate_id)

            def initialize(listener, options)
              @listener = listener
              @options = options
            end

            def policies
              PolicyCollection.new(@listener.policies, self, @options)
            end

            def eql?(dsl)
              not has_difference_protocol_port?(dsl) and compare_server_certificate(dsl) and compare_ssl_certificate_id(dsl)
            end

            def update(dsl)
              log(:info, 'Update Listener', :green, log_id)

              compare_server_certificate(dsl) do |old_data, new_data|
                log(:info, "  server_certificate:", :green)
                log(:info, Kelbim::Utils.diff(old_data, new_data, :color => @options[:color], :indent => '    '), false)

                unless @options.dry_run
                  ss = @options.iam.server_certificates[dsl.server_certificate]

                  unless ss
                    raise "Can't find ServerCertificate: #{ss_name} in #{log_id}"
                  end

                  @listener.server_certificate = ss
                  @options.updated = true
                end
              end

              compare_ssl_certificate_id(dsl) do |old_data, new_data|
                log(:info, "  ssl_certificate_id:", :green)
                log(:info, Kelbim::Utils.diff(old_data, new_data, :color => @options[:color], :indent => '    '), false)

                unless @options.dry_run
                  @listener.ssl_certificate_id = @dsl.ssl_certificate_id
                  @options.updated = true
                end
              end
            end

            def update_policies(policy_list, old_policy_list)
              old_data = old_policy_list.map {|i| i.name }.sort
              new_data = policy_list.map {|i| i.name }.sort
              log(:info, 'Update Listener Policies', :green, log_id)
              log(:info, Kelbim::Utils.diff(old_data, new_data, :color => @options[:color], :indent => '    '), false)

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

              # XXX:
              if not aws_server_certificate.nil? and dsl.server_certificate.nil?
                log(:warn, "It can not be server_certificate to nil", :yellow, log_id)
                return true
              end

              same = (aws_server_certificate == dsl.server_certificate)
              yield(aws_server_certificate, dsl.server_certificate) if !same && block_given?
              return same
            end

            def compare_ssl_certificate_id(dsl)
              # XXX:
              if not @listener.ssl_certificate_id.nil? and dsl.ssl_certificate_id.nil?
                log(:warn, "It can not be ssl_certificate_id to nil", :yellow, log_id)
                return true
              end

              same = (@listener.ssl_certificate_id == dsl.ssl_certificate_id)
              yield(@listener.ssl_certificate_id, dsl.ssl_certificate_id) if !same && block_given?
              return same
            end
          end # Listener
        end # ListenerCollection
      end # LoadBalancer
    end # LoadBalancerCollection
  end # ELBWrapper
end # Kelbim
