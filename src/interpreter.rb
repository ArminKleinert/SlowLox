require_relative './environment.rb'
require_relative './lox_callable.rb'
require_relative './lox_function.rb'
require_relative './runtime_error.rb'
require_relative './lox_class.rb'

module RbLox
  class Interpreter
    #include RbLox

    attr_reader :globals

    def initialize
      @globals = RbLox::Environment.new
      @environment = globals
      @locals = Hash.new # Map<Expr, Integer>

      @globals.define("clock", RbLox.loxc { |_, _| Time.now.to_f })
    end

    # statements : Array<Stmt>
    def interpret(statements)
      begin
        statements.each do |statement|
          execute statement
        end
      rescue LoxRuntimeError => error
        Lox.runtime_error error
      end
    end

    def evaluate(expr)
      expr.accept(self)
    end

    def execute(stmt)
      stmt.accept(self)
    end

    # expr : Expr
    # depth : Int
    def resolve(expr, depth)
      @locals[expr] = depth
    end

    # statements : Array<Stmt>
    # environment : Environment
    def execute_block(statements, environment)
      previous = @environment
      begin
        @environment = environment

        statements.each do |statement|
          execute statement
        end
      ensure
        @environment = previous
      end
      nil
    end

    def visit_block_stmt(stmt)
      execute_block stmt.statements, Environment.new(@environment)
    end

    def visit_class_stmt(stmt)
      superclass = nil
      unless stmt.superclass.nil?
        superclass = evaluate stmt.superclass
        unless superclass.is_a?(LoxClass)
          raise LoxRuntimeError.new(stmt.superclass.name, "Superclass must be a class.")
        end
      end

      @environment.define stmt.name.lexeme, nil

      unless stmt.superclass.nil?
        @environment = Environment.new(@environment)
        @environment.define "super", superclass
      end

      # Map<String, LoxFunction>
      methods = Hash.new

      stmt.methods.each do |method|
        is_init_fn = method.name.lexeme == "init"
        function = LoxFunction.new(method, @environment, is_init_fn)
        methods[method.name.lexeme] = function
      end

      klass = LoxClass.new(stmt.name.lexeme, superclass, methods)

      unless superclass.nil?
        @environment = @environment.enclosing
      end

      @environment[stmt.name] = klass
      nil
    end

    def visit_expression_stmt(stmt)
      evaluate stmt.expression
      nil
    end

    def visit_function_stmt(stmt)
      function = LoxFunction.new(stmt, @environment, false)
      @environment.define stmt.name.lexeme, function
      nil
    end

    def visit_if_stmt(stmt)
      if is_truthy(evaluate(stmt.condition))
        execute stmt.then_branch
      elsif !stmt.else_branch.nil?
        execute stmt.else_branch
      else
        nil
      end
    end

    def visit_print_stmt(stmt)
      value = evaluate stmt.expression
      puts stringify(value)
      nil
    end

    def visit_return_stmt(stmt)
      value = nil
      value = evaluate(stmt.value) unless stmt.value.nil?
      raise Return.new(value)
    end

    def visit_var_stmt(stmt)
      value = nil
      unless stmt.initializer.nil?
        value = evaluate stmt.initializer
      end

      @environment.define(stmt.name.lexeme, value)
      nil
    end

    def visit_while_stmt(stmt)
      while is_truthy(evaluate(stmt.condition))
        execute stmt.body
      end
      nil
    end

    def visit_assign_expr(expr)
      value = evaluate expr.value

      distance = @locals[expr]
      if distance.nil?
        @globals.assign(expr.name, value)
      else
        @environment.assign_at(distance, expr.name, value)
      end

      value
    end

    def visit_binary_expr(expr)
      left = evaluate expr.left
      right = evaluate expr.right

      case expr.operator.type
      when :bang_equal
        !is_equal?(left, right)
      when :equal_equal
        is_equal? left, right
      when :greater
        check_number_operands expr.operator, left, right
        left > right
      when :greater_equal
        check_number_operands expr.operator, left, right
        left >= right
      when :less
        check_number_operands expr.operator, left, right
        left < right
      when :less_equal
        check_number_operands expr.operator, left, right
        left <= right
      when :minus
        check_number_operands expr.operator, left, right
        left - right
      when :plus
        if left.is_a?(Float) && right.is_a?(Float)
          left + right
        elsif left.is_a?(String) && right.is_a?(String)
          left + right
        else
          raise LoxRuntimeError.new(expr.operator, "Operands must be two numbers or two strings.")
        end
      when :slash
        check_number_operands expr.operator, left, right
        left / right
      when :star
        check_number_operands expr.operator, left, right
        left * right
      else
        nil
      end
    end

    # Why not swap the evaluation of arguments and the check 
    # ``unless callee.is_a?(LoxCallable)``?
    def visit_call_expr(expr)
      callee = evaluate expr.callee

      # Apply the block to each item in expr.arguments
      # and construct a new list from the results.
      # Ruby:
      # https://ruby-doc.org/core-2.7.0/Enumerable.html#method-i-map
      # https://ruby-doc.org/core-2.7.0/Array.html#method-i-map
      # Java 8 streams:
      # https://docs.oracle.com/javase/8/docs/api/java/util/stream/Stream.html#map-java.util.function.Function-
      arguments = expr.arguments.map do |argument|
        evaluate argument
      end

      unless callee.is_a?(LoxCallable)
        raise LoxRuntimeError.new(expr.paren, "Can only call functions and classes.")
      end

      function = callee
      if arguments.size == function.arity
        function.call self, arguments
      else
        message = "Expected #{function.arity} arguments but got #{arguments.size}."
        raise LoxRuntimeError.new(expr.paren, message)
      end
    end

    def visit_get_expr(expr)
      object = evaluate expr.object

      if object.is_a?(LoxInstance)
        object[expr.name]
      else
        raise LoxRuntimeError.new(expr.name, "Only instances have properties.")
      end
    end

    def visit_grouping_expr(expr)
      evaluate expr.expression
    end

    def visit_literal_expr(expr)
      expr.value
    end

    def visit_logical_expr(expr)
      left = evaluate expr.left

      if expr.operator.type == :or
        is_truthy(left) ? left : evaluate(expr.right)
      else
        !is_truthy(left) ? left : evaluate(expr.right)
      end
    end

    def visit_set_expr(expr)
      object = evaluate expr.object

      if object.is_a?(LoxInstance)
        value = evaluate expr.value
        object[expr.name] = value
        value
      else
        raise LoxRuntimeError.new(expr.name, "Only instances have fields.")
      end
    end

    def visit_super_expr(expr)
      distance = @locals[expr]
      super_class = @environment.get_at distance, "super"
      object = @environment.get_at distance - 1, "this"

      method = super_class.find_method expr.method.lexeme

      if method.nil?
        raise LoxRuntimeError.new(expr.method, "Undefined property '#{expr.method.lexeme}'.")
      else
        method.bind object
      end
    end

    def visit_this_expr(expr)
      look_up_variable expr.keyword, expr
    end

    def visit_unary_expr(expr)
      right = evaluate expr.right

      case expr.operator.type
      when :bang
        !is_truthy(right)
      when :minus
        check_number_operand expr.operator, right
        -right
      else
        nil
      end
    end

    def visit_variable_expr(expr)
      look_up_variable expr.name, expr
    end

    # All methods below are private.

    private

    # name : Token
    # expr : Expr
    def look_up_variable(name, expr)
      distance = @locals[expr]
      if distance.nil?
        @globals[name]
      else
        @environment.get_at distance, name.lexeme
      end
    end

    # operator : Token
    # operand : Object
    def check_number_operand(operator, operand)
      unless operand.is_a?(Float)
        raise LoxRuntimeError.new(operator, "Operand must be a number.")
      end
    end

    # operator : Token
    # left : Object
    # right : Object
    def check_number_operands(operator, left, right)
      unless left.is_a?(Float) && right.is_a?(Float)
        raise LoxRuntimeError.new(operator, "Operands must be numbers.")
      end
    end

    def is_truthy(object)
      # nil, false -> false
      # everything else -> true
      !!object
    end

    def is_equal?(a, b)
      # Ruby's #== operator is implemented as a method just like
      # #equal? and #eql?. It works on nil values too.
      a == b
    end

    # Again, this is pretty much the original code again.
    # There are a few things to note though.
    # Ruby has multible different methods for turning objects into
    # strings. The most important ones are:
    # https://ruby-doc.org/core-2.7.0/Object.html#method-i-to_s
    # https://ruby-doc.org/core-2.7.0/Object.html#method-i-inspect
    # While nil.to_s returns "", nil.inspect does return "nil".
    # However, the #to_s and #inspect methods have very different
    # behaviour on other classes too. If you want a string conversion
    # which is most Java-like, use #to_s
    def stringify(object)
      if object.nil?
        "nil"
      elsif object.is_a?(Float)
        text = object.to_s
        text.end_with?(".0") ? text[0...-2] : text
      else
        object.to_s
      end
    end
  end
end
