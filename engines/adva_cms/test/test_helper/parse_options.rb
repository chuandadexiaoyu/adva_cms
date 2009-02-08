OptionParser.new do |o|
  o.on('-l', '--line=LINE', "Run tests defined at the given LINE.") do |line|
    With.options[:line] = line
  end
  
  o.on('-w', '--with=ASPECTS', "Run tests defined for the given ASPECTS (comma separated).") do |aspects|
    With.aspects += aspects.split(/,/)
  end
end.parse!(ARGV)