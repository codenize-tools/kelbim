module Kelbim
  class ELBWrapper
    class LoadBalancerCollection
      class LoadBalancer
        class ListenerCollection
          include Logger::ClientHelper

          class << self
            def create_mock_listener(dsl, load_balancer)
              lstnr = OpenStruct.new({
                :protocol          => dsl.protocol,
                :port              => dsl.port,
                :instance_protocol => dsl.instance_protocol,
                :instance_port     => dsl.instance_port,
                :policies          => [], # Listener作成時に同時にPolicyを作成することはできない
                :load_balancer     => load_balancer,
              })

              if dsl.server_certificate
                lstnr.server_certificate = OpenStruct.new(:name => dsl.server_certificate)
              end

              return lstnr
            end

            def create_listener_options(dsl, iam)
              lstnr_opts = {
                :protocol          => dsl.protocol,
                :port              => dsl.port,
                :instance_protocol => dsl.instance_protocol,
                :instance_port     => dsl.instance_port,
              }

              if (ss_name = dsl.server_certificate)
                ss = iam.server_certificates[ss_name]

                unless ss
                  raise "Can't find ServerCertificate: #{ss_name} in #{load_balancer.vpc_id || :classic} > #{@load_balancer.name}"
                end

                lstnr_opts[:server_certificate] = ss.arn
              end

              return lstnr_opts
            end
          end # of class methods

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

            lstnr = nil

            if @options.dry_run
              lstnr = self.class.create_mock_listener(dsl, @load_balancer)
            else
              lstnr_opts = self.class.create_listener_options(dsl, @options.iam)

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
