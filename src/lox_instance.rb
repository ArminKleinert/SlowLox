require_relative './runtime_error.rb'

module RbLox
  class LoxInstance

    def initialize(klass)
      @klass = klass
      @fields = Hash.new
    end

    # Return Object
    # name : Token
    def get(name)
      if @fields.has_key?(name.lexeme)
        @fields[name.lexeme]
      else
        method = @klass.find_method name.lexeme
        unless method.nil?
          method.bind self
        else
          message = "Undefined property '#{name.lexeme}'."
          raise LoxRuntimeError.new(name, message)
        end
      end
    end

    # Create an alias for get
    # https://ruby-doc.org/core-2.7.0/Module.html#method-i-alias_method
    # https://blog.bigbinary.com/2012/01/08/alias-vs-alias-method.html
    alias_method :[], :get

    # name : Token
    # value : Object
    def set(name, value)
      @fields[name.lexeme] = value
    end

    alias_method :[]=, :set

    def to_s
      "#{@klass.name} instance"
    end
  end
end
