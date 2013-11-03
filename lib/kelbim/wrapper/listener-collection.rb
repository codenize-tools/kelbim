require 'ostruct'
require 'kelbim/wrapper/listener'
require 'kelbim/logger'

module Kelbim
  class ELBWrapper
    class LoadBalancerCollection
      class LoadBalancer
        class ListenerCollection
          include Logger::ClientHelper

          def initialize(listeners, load_balancer, options)
            @listeners = listeners
            @load_balancer = load_balancer
            @options = options
          end

          def each
            @listeners.each do |lstnr|
              yield(Listener.new(lstnr, @options))
            end
          end

          def create(dsl)
            log_id = [[dsl.protocol, dsl.port], [dsl.instance_protocol, dsl.instance_port]].map {|i| i.inspect }.join(' => ')
            log_id = "#{@load_balancer.vpc_id || :classic} > #{@load_balancer.name} > #{log_id}"
            log(:info, 'Create Listener', :cyan, log_id)

            if @options.dry_run
              lstnr = OpenStruct.new({
                :protocol          => dsl.protocol,
                :port              => dsl.port,
                :instance_protocol => dsl.instance_protocol,
                :instance_port     => dsl.instance_port,
                :policies          => dsl.policies.map {|i| PolicyCollection.create_mock_policy(i) },
                :scheme            => dsl.scheme,
              })

              if dsl.server_certificate
                lstnr.server_certificate = OpenStruct.new(:name => dsl.server_certificate)
              end
            else
              lstnr_opts = {
                :protocol          => dsl.protocol,
                :port              => dsl.port,
                :instance_protocol => dsl.instance_protocol,
                :instance_port     => dsl.instance_port,
                :scheme            => dsl.scheme,
              }

              if (ss_name = dsl.server_certificate)
                ss = @options.iam.server_certificates[ss_name]

                unless ss
                  raise "Can't find ServerCertificate: #{ss_name} in #{load_balancer.vpc_id || :classic} > #{@load_balancer.name}"
                end

                lstnr_opts[:server_certificate] = ss.arn
              end

              # lstnr_optsは破壊的に更新される
              lstnr = @listeners.create(lstnr_opts.dup)
              @options.updated = true

              # XXX: 新規作成後、_descriptionはセットされない
              fix_new_listener(lstnr, lstnr_opts)
            end

            Listener.new(lstnr, @options)
          end

          private
          def fix_new_listener(lstnr, lstnr_opts)
            lstnr.instance_variable_set(:@__server_certificate__, lstnr_opts[:server_certificate])

            def lstnr.server_certificate
              if @__server_certificate__
                OpenStruct.new(:name => @__server_certificate__)
              else
                nil
              end
            end

            def lstnr.policy_names; []; end
          end
        end # ListenerCollection
      end # LoadBalancer
    end # LoadBalancerCollection
  end # ELBWrapper
end # Kelbim
