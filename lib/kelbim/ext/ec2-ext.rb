require 'aws-sdk-v1'

module AWS
  class EC2
    def instance_names
      vpc_instance_id_names = {}

      self.instances.each do |i|
        vpc_instance_id_names[i.vpc_id] ||= {}
        vpc_instance_id_names[i.vpc_id][i.id] = i.tags['Name']
      end

      return vpc_instance_id_names
    end

    def security_group_names
      vpc_sg_id_names = {}

      self.security_groups.each do |i|
        vpc_sg_id_names[i.vpc_id] ||= {}
        vpc_sg_id_names[i.vpc_id][i.id] = i.name
      end

      return vpc_sg_id_names
    end
  end # EC2
end # AWS
