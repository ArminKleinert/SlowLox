require_relative './stmt.rb'
require_relative './expr.rb'
require_relative './token.rb'

module RbLox
  class Parser
    class ParseError < RuntimeError
    end
    
    # token : Array<Token>
    def initialize(tokens)
      @current = 0
      @tokens = tokens
    end
    
    def parse
      statements = []
      statements << declaration() until is_at_end?
      statements
    end
    
    def expression
      assignment()
    end
    
    def declaration
      begin
        if match(:class)
          class_declaration()
        elsif match(:fun)
          function 'function'
        elsif match(:var)
          var_declaration()
        else
          statement()
        end
      rescue ParseError => error
        synchronize()
        nil
      end
    end
    
    def class_declaration
      name = consume :identifier, 'Expect class name.'
      superclass = nil
      
      if match(:less)
        consume :identifier, 'Expect superclass name.'
        superclass = Expr::Variable.new(previous())
      end
      
      consume :left_brace, "Expect '(' before class body."
      
      methods = []
      methods << function('method') until (check(:right_brace) || is_at_end?())
      
      consume :right_brace, "Expect ')' after class body."
      
      Stmt::Class.new name, superclass, methods
    end
    
    def statement
      if match(:for)
        for_statement()
      elsif match(:if)
        if_statement()
      elsif match(:print)
        print_statement()
      elsif match(:return)
        return_statement()
      elsif match(:while)
        while_statement()
      elsif match(:left_brace)
        Stmt::Block.new(block())
      else
        expression_statement()
      end
    end
    
    def for_statement
      consume :left_paren, "Expect '(' after 'for'."
      
      initializer = nil
      
      if match(:semicolon)
        initializer = nil
      elsif match(:var)
        initializer = var_declaration()
      else
        initializer = expression_statement()
      end
      
      condition = nil
      unless check(:semicolon)
        condition = expression()
      end
      consume :semicolon, "Expect ';' after loop condition."
      
      increment = nil
      unless check(:right_paren)
        increment = expression()
      end
      consume :right_paren, "Expect ')' after for clauses."
      
      body = statement()
      
      unless increment.nil?
        body = Stmt::Block.new [body, Stmt::Expression.new(increment)]
      end
      
      condition = Expr::Literal.new(true) if condition.nil?
      body = Stmt::While.new(condition, body)
      
      # [initializer, body] is a list literal
      body = Stmt::Block.new([initializer, body]) unless initializer.nil?
      
      body
    end
    
    def if_statement
      consume :left_paren, "Expect '(' after 'if'."
      condition = expression()
      consume :right_paren, "Expect ')' after if condition."
      
      then_branch = statement()
      else_branch = match(:else) ? statement() : nil
      
      Stmt::If.new condition, then_branch, else_branch
    end
    
    def print_statement
      value = expression()
      consume :semicolon, "Expect ';' after value."
      Stmt::Print.new value
    end
    
    def return_statement
      keyword = previous()
      value = check(:semicolon) ? nil : expression()
      consume :semicolon, "Expect ';' after return value."
      Stmt::Return.new keyword, value
    end
    
    def var_declaration
      name = consume :identifier, "Expect variable name."
      
      initializer = nil
      if match(:equal)
        initializer = expression()
      end
      
      consume :semicolon, "Expect ';' after variable declaration."
      Stmt::Var.new name, initializer
    end
    
    def while_statement
      consume :left_paren, "Expect '(' after 'while'."
      condition = expression()
      consume :right_paren, "Expect ')' after condition."
      body = statement()
      
      Stmt::While.new condition, body
    end
    
    def expression_statement
      expr = expression()
      consume :semicolon, "Expect ';' after expression."
      Stmt::Expression.new expr
    end
    
    def function(kind)
      name = consume :identifier, "Expect #{kind} name."
      consume :left_paren, "Expect '(' after #{kind} name."
      
      parameters = []
      unless check(:right_paren)
        # This is a do-while loop
        loop do
          if parameters.size >= 255
            error peek(), "Cannot have more than 255 parameters."
          end
          
          parameters << consume(:identifier, "Expect parameter name.")
          
          break unless match(:comma)
        end
      end
    
      consume :right_paren, "Expect ')' after parameters."
      
      consume :left_brace, "Expect '{' before #{kind} body."
      body = block()
      Stmt::Function.new name, parameters, body
    end
    
    def block
      statements = []
      statements << declaration() until (check(:right_brace) || is_at_end?)
      consume :right_brace, "Expect '}' after block."
      statements
    end
    
    def assignment
      expr = or_expr()
      
      # In the original code, 2 explicit returns were used in the following if.
      # Explicit returns are discouraged, so here, expr is re-assigned instead
      # and implicitly returns at the end.
      if match(:equal)
        # Variable was called 'equals' in the original code.
        # I changed the name because I found it to be clearer.
        equals_operator = previous()
        
        value = assignment()
        
        if expr.is_a?(Expr::Variable)
          name = expr.name
          expr = Expr::Assign.new name, value
        elsif expr.is_a?(Expr::Get)
          get_expr = expr # This assignment is not necessary because of Rubys dynamic typing
          expr = Expr::Set.new get_expr.object, get_expr.name, value
        else
          error equals_operator, "Invalid assignment target."
        end
      end
      
      expr
    end
    
    # Original name: or
    # or is a reserved keyword in Ruby. It does the same as
    # || but has a lower precedence.
    def or_expr
      expr = and_expr()
      
      while match(:or)
        operator = previous()
        right = and_expr()
        expr = Expr::Logical.new expr, operator, right
      end
      
      expr
    end
    
    # Original name: and
    # and is a reserved keyword in Ruby. It does the same as
    # && but has a lower precedence.
    def and_expr
      expr = equality()
      
      while match(:and)
        operator = previous()
        right = equality()
        expr = Expr::Logical.new expr, operator, right
      end
      
      expr
    end
    
    def equality
      expr = comparison()
      
      while match(:bang_equal, :equal_equal)
        operator = previous()
        right = comparison()
        Expr::Binary.new expr, operator, right
      end
      
      expr
    end
    
    def comparison
      expr = addition()
      
      while match(:greater, :greater_equal, :less, :less_equal)
        operator = previous()
        right = addition()
        expr = Expr::Binary.new expr, operator, right
      end
      
      expr
    end
    
    def addition
      expr = multiplication()
      
      while match(:minus, :plus)
        operator = previous()
        right = multiplication()
        expr = Expr::Binary.new expr, operator, right
      end
      
      expr
    end
    
    def multiplication
      expr = unary()
      
      while match(:slash, :star)
        operator = previous()
        right = unary()
        expr = Expr::Binary.new expr, operator, right
      end
      
      expr
    end
    
    def unary
      if match(:bang, :minus)
        operator = previous()
        right = unary()
        return Expr::Unary.new operator, right
      end
      call()
    end
    
    def finish_call(callee)
      arguments = []
      
      unless check(:right_paren)
        # This is a do-while loop
        loop do
          if arguments.size >= 255
            error peek(), "Cannot have more than 255 arguments."
          end
          
          arguments << expression()
          
          break unless match(:comma)
        end
      end 
      
      paren = consume :right_paren, "Expect ')' after arguments."
      
      Expr::Call.new callee, paren, arguments
    end
    
    def call
      expr = primary()
      
      loop do
        if match(:left_paren)
          expr = finish_call(expr)
        elsif match(:dot)
          name = consume :identifier, "Expect property name after '.'."
          expr = Expr::Get.new expr, name
        else
          break
        end
      end
      
      expr
    end
    
    def primary
      return Expr::Literal.new false if match(:false)
      return Expr::Literal.new true if match(:true)
      return Expr::Literal.new nil if match(:nil)
      
      if match(:number, :string)
        return Expr::Literal.new previous().literal
      end
      
      if match(:super)
        keyword = previous()
        consume :dot, "Expect '.' after 'super'."
        method = consume :identifier, "Expect superclass method name."
        return Expr::Super.new keyword, method
      end
      
      if match(:this)
        return Expr::This.new previous()
      end
      
      if match(:identifier)
        return Expr::Variable.new previous()
      end
      
      if match(:left_paren)
        expr = expression()
        consume :right_paren, "Expect ')' after expression."
        return Expr::Grouping.new expr
      end
      
      raise error(peek(), "Expect expression.")
    end
    
    def match(*types)
      types.each do |type|
        if check(type)
          advance()
          return true
        end
      end
      
      false
    end
    
    def consume(type, message)
      if check(type)
        advance()
      else
        error peek(), message
      end
    end
    
    def check(type)
      if is_at_end?
        false
      else
        peek().type == type
      end
    end
    
    def advance
      @current += 1 unless is_at_end?
      previous()
    end
    
    def is_at_end?
      peek().type == :eof
    end
    
    def peek
      @tokens[@current]
    end
    
    def previous
      @tokens[@current - 1]
    end
    
    def error(token, message)
      Lox.error token, message
      ParseError.new
    end

    # This variable is only used in synchronize(). Having it as a final, static, frozen variable
    # makes it more performant than a local variable.
    # It can be argued about which version of the code is better, but this is what I am used to
    # from functional programming languages, so I went with it.
    @@Breaking_symbols = [:class, :fun, :var, :for, :if, :while, :print, :return].freeze
    def synchronize
      advance()
      until is_at_end?
        break if previous().type == :semicolon
        break if @@Breaking_symbols.include?(peek().type)
        advance()
      end
    end
  end
end
