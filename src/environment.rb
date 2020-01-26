module RbLox
  class Environment
    attr_reader :enclosing
    
    def initialize(enclosing = nil)
      @enclosing = enclosing
      @values = Hash.new # Map<String, Object
    end
    
    # name : Token
    def get(name)
      if @values.has_key?(name.lexeme)
        @values[name.lexeme]
      elsif @enclosing # if enclosing != nil
        @enclosing.get name
      else
        raise LoxRuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
      end
    end
    
    # Create an alias for get
    # environment.get(...)
    # environment[...]
    # Both of the above now do the same.
    # https://ruby-doc.org/core-2.7.0/Module.html#method-i-alias_method
    # https://blog.bigbinary.com/2012/01/08/alias-vs-alias-method.html
    alias_method :[], :get
        
    # name : Token
    # value : Object
    def assign(name, value)
      if @values.has_key?(name.lexeme)
        values[name.lexeme] = value
      elsif @enclosing # if enclosing != nil
        @enclosing.assign name, value
      else
        raise LoxRuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
      end
    end
    
    # Create an alias for get
    # environment.get(name, value)
    # environment[name] = value
    # Both of the above now do the same.
    # https://ruby-doc.org/core-2.7.0/Module.html#method-i-alias_method
    # https://blog.bigbinary.com/2012/01/08/alias-vs-alias-method.html
    alias_method :[]=, :assign
    
    # name : String
    # value : Object
    def define(name, value)
      @values[name] = value
    end
    
    # Returns Environment
    # distance : int
    def ancestor(distance)
      environment = self
      1.upto(distance) do |i|
        environment = environment.enclosing
      end
      environment
    end
    
    # Returns Object
    # distance : int
    # name : String
    def get_at(distance, name)
      # The original made use of the fact that privates in 
      # Java can be accessed by members of the same type:
      #   ancestor(distance).values.get(name);
      # This is not possible in Ruby.
      # At the bottom of the file, a protected getter
      # is defined for @values though.
      ancestor(distance).values[name]
    end
    
    # distance : int
    # name : Token
    # value : Object
    def assign_at(distance, name, value)
      # The original made use of the fact that privates in 
      # Java can be accessed by members of the same type:
      #   ancestor(distance).values.put(name.lexeme, value);
      # This is not possible in Ruby.
      # At the bottom of the file, a protected getter
      # is defined for @values though.
      ancestor(distance).values[name.lexeme] = value
    end
    
    def to_s
      result = values.to_s
      result << " -> #{@enclosing.to_s}" if enclosing
      result
    end
    
    # All methods defined below are protected instead of public.
    # https://ruby-doc.org/core-2.7.0/Module.html#method-i-protected
    protected
    
    def values
      @values
    end
  end
end
