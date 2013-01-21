module Puppet::Parser::Functions
  newfunction(:subtract_array, :type => :rvalue) do |args|
    args[0] - args[1]
  end
end
