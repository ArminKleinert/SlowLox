require_relative './lox_callable.rb'
require_relative './environment.rb'
require_relative './return.rb'

module RbLox
  class LoxFunction < LoxCallable

    # declaration : Stmt.Function
    # closure : Environment
    # is_initializer : boolean
    def initialize(declaration, closure, is_initializer)
      @declaration = declaration
      @closure = closure
      @is_initializer = is_initializer
    end
    
    # instance : LoxInstance
    def bind(instance)
      environment = Environment.new(@closure)
      environment.define "this", instance
      LoxFunction.new @declaration, environment, @is_initializer
    end
    
    def to_s
      "<fn #{@declaration.name.lexeme}>"
    end
    
    def arity
      @declaration.params.size
    end

    # interpreter : Interpreter
    # arguments : Array<Object>
    def call(interpreter, arguments)
      environment = Environment.new @closure
      
      @declaration.params.each_with_index do |param, index|
        environment.define param.lexeme, arguments[index]
      end
      
      begin
        interpreter.execute_block @declaration.body, environment
      rescue Return => return_value
        @is_initializer ? @closure.get_at(0, "this") : return_value.value
      else # No exception was thrown
        @is_initializer ? @closure.get_at(0, "this") : nil
      end
    end
  end
end
