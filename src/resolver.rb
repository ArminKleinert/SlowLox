module RbLox
  class Resolver # implements Stmt::Visitor<Void>, Expr::Visitor<Void>

    # enum FunctionType
    # :none
    # :function
    # :initializer
    # :method
    # end

    # enum ClassType
    # :none
    # :class
    # :subclass
    # end

    # Rubys Arrays provide almost all methods needed
    # for a Stack.
    class Stack < Array
      def peek
        self.last
      end
    end

    def initialize(interpreter)
      @interpreter = interpreter
      @scopes = Stack.new # Stack of Map<String, Boolean>
      @current_class = :none # ClassType
      @current_function = :none # FunctionType
    end

    # statements : Array<Stmt>
    def resolve(statements)
      # Apply the resolve_single method on each statement
      # in the list statements.
      # This is a shortcut for a verbose 3-line block.
      # See https://stackoverflow.com/questions/18252630/how-to-turn-a-ruby-method-into-a-block
      statements.each(&method(:resolve_single))
    end
    
    def visit_block_stmt(stmt)
      begin_scope()
      resolve stmt.statements
      end_scope()
      nil
    end
    
    def visit_class_stmt(stmt)
      enclosing_class = @current_class
      @current_class = :class
      
      declare stmt.name
      define stmt.name
      
      if (!stmt.superclass.nil? &&
          stmt.name.lexeme == stmt.superclass.name.lexeme)
        Lox.error(stmt.superclass.name,
          'A class cannot inherit from itself.')
      end
      
      unless stmt.superclass.nil?
        @current_class = :subclass
        resolve_single stmt.superclass
      end
      
      unless stmt.superclass.nil?
        begin_scope()
        @scopes.peek()['super'] = true
      end
      
      begin_scope()
      @scopes.peek()['this'] = true
      
      stmt.methods.each do |method|
        declaration = :method # FunctionType
        
        if method.name.lexeme == 'init'
          declaration = :initializer
        end
        
        resolve_function(method, declaration)
      end
      
      end_scope()
      end_scope() unless stmt.superclass.nil?
      
      @current_class = enclosing_class
      nil
    end
    
    def visit_expression_stmt(stmt)
      resolve_single stmt.expression
      nil
    end
    
    def visit_function_stmt(stmt)
      declare stmt.name
      define stmt.name
      
      resolve_function stmt, :function
      nil
    end
    
    def visit_if_stmt(stmt)
      resolve_single stmt.condition
      resolve_single stmt.then_branch
      resolve_single(stmt.else_branch) unless stmt.else_branch.nil?
      nil
    end
    
    def visit_print_stmt(stmt)
      resolve_single stmt.expression
      nil
    end
    
    def visit_return_stmt(stmt)
      if @current_function == :none
        Lox.error stmt.keyword, 'Cannot return from top-level code.'
      end
      
      unless stmt.value.nil?
        if @current_function == :initializer
          Lox.error stmt.keyword, 'Cannot return from an initializer.'
        end
        
        resolve_single stmt.value
      end
      
      nil
    end
    
    def visit_var_stmt(stmt)
      declare stmt.name
      resolve_single(stmt.initializer) unless stmt.initializer.nil?
      define stmt.name
      nil
    end
    
    def visit_while_stmt(stmt)
      resolve_single stmt.condition
      resolve_single stmt.body
      nil
    end
    
    def visit_assign_expr(expr)
      resolve_single expr.value
      resolve_local expr, expr.name
      nil
    end
    
    def visit_binary_expr(expr)
      resolve_single expr.left
      resolve_single expr.right
      nil
    end
    
    def visit_call_expr(expr)
      resolve_single expr.callee
      # Same principle as explained in the resolve(...) method
      expr.arguments.each(&method(:resolve_single))
      nil
    end
    
    def visit_get_expr(expr)
      resolve_single expr.object
      nil
    end
    
    def visit_grouping_expr(expr)
      resolve_single expr.expression
      nil
    end
    
    def visit_literal_expr(expr)
      nil
    end
    
    def visit_logical_expr(expr)
      resolve_single expr.left
      resolve_single expr.right
      nil
    end
    
    def visit_set_expr(expr)
      resolve_single expr.value
      resolve_single expr.object
      nil
    end
    
    def visit_super_expr(expr)
      if @current_class == :none
        Lox.error expr.keyword, "Cannot use 'super' outside of a class."
      elsif @current_class != :subclass
        Lox.error expr.keyword, "Cannot use 'super' in a class with no superclass."
      end
      
      resolve_local expr, expr.keyword
      nil
    end
    
    def visit_this_expr(expr)
      if @current_class == :none
        Lox.error expr.keyword, "Cannot use 'this' outside of a class."
      else
        resolve_local expr, expr.keyword
      end
      
      nil
    end
    
    def visit_unary_expr(expr)
      resolve_single expr.right
      nil
    end
    
    def visit_variable_expr(expr)
      if !@scopes.empty? && @scopes.peek()[expr.name.lexeme] == false
        Lox.error expr.name, 'Cannot read local variable in its own initializer.'
      else
        resolve_local expr, expr.name
      end
      
      nil
    end
    
    def resolve_single(expr)
      expr.accept(self)
    end
    
    # function : Stmt::Function
    # type : FunctionType
    def resolve_function(function, type)
      enclosing_function = @current_function
      @current_function = type
      
      begin_scope()
      function.params.each do |param|
        declare param
        define param
      end
      resolve function.body
      end_scope()
      
      @current_function = enclosing_function
    end
    
    
    def begin_scope
      @scopes << Hash.new # Map<String, Boolean>
    end
    
    def end_scope
      @scopes.pop
    end
    
    
    # name : Token
    def declare(name)
      return if @scopes.empty?
      
      scope = @scopes.peek()
      
      if scope.has_key?(name.lexeme)
        Lox.error name, 'Variable with this name already declared in this scope.'
      end
      
      scope[name.lexeme] = false
    end
    
    # name : Token
    def define(name)
      @scopes.peek()[name.lexeme] = true unless @scopes.empty?
    end
    
    # expr : Expr
    # name : Token
    def resolve_local(expr, name)
      # Definitly not the most readable version, 
      # but it gets the point across.
      # See Interpreter.resolve(...)
      (0...(@scopes.size)).reverse_each do |i|
        if @scopes[i].has_key?(name.lexeme)
          @interpreter.resolve expr, (@scopes.size - 1 - i)
          break
        end
      end
    end
  end
end 
