require_relative './lox_callable.rb'
require_relative './lox_instance.rb'

module RbLox
  class LoxClass < LoxCallable

    def initialize(name, superclass, methods)
      @superclass = superclass
      @name = name
      @methods = methods
    end

    def find_method(name)
      if @methods.has_key?(name)
        @methods[name]
      elsif @superclass.nil?
        nil
      else
        @superclass.find_method(name)
      end
    end

    def to_s
      @name
    end

    def arity
      initializer = find_method "init"
      initializer.nil? ? 0 : initializer.arity
    end

    # interpreter : Interpreter
    # arguments : Array<Object>
    def call(interpreter, arguments)
      instance = LoxInstance.new self
      initializer = find_method "init"

      unless initializer.nil?
        initializer.bind(instance).call(interpreter, arguments)
      end

      instance
    end
  end
end
