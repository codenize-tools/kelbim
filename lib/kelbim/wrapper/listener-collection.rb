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
            # XXX: logging
            #log(:info, 'Create Listener', :cyan, "#{vpc || :classic} > #{dsl.name}")

            if @options.dry_run
              lstnr = OpenStruct.new({
                :protocol          => dsl.protocol,
                :port              => dsl.port,
                :instance_protocol => dsl.instance_protocol,
                :instance_port     => dsl.instance_port,
                :policies          => [], # XXX:
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

              # XXX: 新規作成後にserver_certificateを取得できない問題の対応
              if lstnr_opts[:server_certificate]
                def lstnr.server_certificate
                  OpenStruct.new(:name => lstnr_opts[:server_certificate])
                end
              end
            end

            Listener.new(lstnr, @options)
          end
        end # ListenerCollection
      end # LoadBalancer
    end # LoadBalancerCollection
  end # ELBWrapper
end # Kelbim
