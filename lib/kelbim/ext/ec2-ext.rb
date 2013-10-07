require 'aws-sdk'

module AWS
  class EC2
    def instance_names
      id_names = {}

      self.instances.each do |i|
        id_names[i.id] = i.tags['Name']
      end

      return id_names
    end
  end
end # AWS
