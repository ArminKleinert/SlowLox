# Load lox.rb, which contains the main code.

$rb_lox_run_main = true
$run_prompt = false
tests = false

if !ARGV.empty?
  ARGV.each_with_index do |e, i|
    if e == "-repl" || e == "-interactive"
      $run_prompt = true
      ARGV[i] = nil
    end
    if e == "-tests"
      tests = true
      ARGV[i] = nil
    end
  end

  ARGV = ARGV.delete nil

  if File.directory? ARGV[0]
    $rb_lox_run_main = false
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
  RbLox::Lox.run_prompt if $run_prompt
else
  require_relative './src/lox.rb'
end

