# Load lox.rb, which contains the main code.

$rblox_runmain = true
$run_prompt = false
tests = false

if !ARGV.empty?
  if ARGV[0] == "-repl" || ARGV[0] == "-interactive"
    $run_prompt = true
    ARGV.shift
  end
  if ARGV[0] == "-tests"
    tests = true
    ARGV.shift
  end
  if File.directory? ARGV[0]
    $rblox_runmain = false
    require_relative './src/lox.rb'
    Dir[ARGV[0].to_s + "/**/*.lox"]
    .sort
    .each do |f|
      if tests
        puts "Test: " << f
        puts RbLox::Lox.run_file f
      else
        RbLox::Lox.run_file f
      end
    end
  end
  require_relative './src/lox.rb'
else
  require_relative './src/lox.rb'
end

