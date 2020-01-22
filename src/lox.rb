require_relative './scanner.rb'
require_relative './parser.rb'
require_relative './resolver.rb'
require_relative './interpreter.rb'

module RbLox
  class Lox
  
    # Make the Lox::new function private.
    private_class_method :new
  
    class << self # Open static class
#      @@Interpreter = Interpreter.new
      
      @@had_error = false
      @@had_runtime_error = false
      
      def run_file(path)
        run(IO.read(path))
      end
      
      def run_prompt
        loop do
          print "> "
          run gets()
          @@had_error = false
        end
      end
      
      def run(source)
        scanner = Scanner.new source
        tokens = scanner.scan_tokens()
        
        parser = Parser.new tokens
        
#        statements = parser.parse()
        
#        return if @@had_error
        
#        resolver = Resolver.new @@Interpreter
#        resolver.resolve statements
        
#        return if @@had_error
        
#        @@Interpreter.interpret statements
      end
      
      # Ruby does not have method overloading. Instead, the
      # following pattern has to be used.
      # Here, either an Integer (line) or a RbLox::Token (token)
      # can be passeed, so the method has to check the type
      # itself.
      # For readability, error(line_or_token, message) handles
      # only numbers. The helper-method error_with_token(...)
      # is called if a Token was passed.
      def error(line_or_token, message)
        if line_or_token.is_a?(Numeric)
          report line_or_token, "", message
        elsif line_or_token.is_a?(Token)
          # Call specialized helper method
          error_with_token(line_or_token, message)
        else
          # Don't know chat to do if neither a number nor a Token is passed.
          raise "Illegal type #{line_or_token.class} given."
        end
      end
      
      # Specialized helper method for error(...)
      def error_with_token(token, message)
        if token.type == TokenType::EOF
          report token.line_or_token, ' at end', message
        else
          report token.line_or_token, " at '#{token.lexeme}'#{message}"
        end
      end
      
      def report(line, where, message)
        STDERR.puts "[line #{line}] Error#{where}: #{message}"
        @@had_error = true
      end
      
      # ScriptError, SecurityError, StandardError, SignalException
      def runtime_error(error)
        STDERR.puts "#{error.message}\n[line #{error.token.line}]"
        @@had_runtime_error = true
      end
    end
    
    private
    
    def intialize
    end
  end
end

if ARGV.size > 1
  STDERR.puts 'Usage: rblox [script]'
  exit 64
elsif ARGV.size == 1
  RbLox::Lox.run_file ARGV[0]
else
  RbLox::Lox.run_prompt()
end
