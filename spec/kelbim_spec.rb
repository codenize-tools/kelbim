require File.expand_path("#{File.dirname __FILE__}/spec_config")

Dir.glob("#{File.dirname __FILE__}/specs/*.rb").each do |fn|
  require fn
end
