module RbLox
  class Stmt
    # For the definition of Stmt::Visitor, see the "visitors" file.
    class Visitor
      def visit_block_stmt(stmt);end
      def visit_class_stmt(stmt);end
      def visit_expression_stmt(stmt);end
      def visit_function_stmt(stmt);end
      def visit_if_stmt(stmt);end
      def visit_print_stmt(stmt);end
      def visit_return_stmt(stmt);end
      def visit_var_stmt(stmt);end
      def visit_while_stmt(stmt);end
    end
    
    class Block < Stmt
      attr_reader :statements # Array<Stmt>
      
      def initialize(statements)
        @statements = statements
      end
      
      def accept(visitor)
        visitor.visit_block_stmt(self)
      end
    end
    
    class Class < Stmt
      attr_reader :name # Token
      attr_reader :superclass # Expr::Variable
      attr_reader :methods # Array<Stmt::Function>
      
      def initialize(name_tkn, superclass, methods)
        @name = name_tkn
        @superclass = superclass
        @methods = methods
      end
      
      def accept(visitor)
        visitor.visit_class_stmt(self)
      end
    end
    
    class Expression < Stmt
      attr_reader :expression # Expr
      
      def initialize(expression)
        @expression = expression
      end
      
      def accept(visitor)
        visitor.visit_expression_stmt(self)
      end
    end
    
    class Function < Stmt
      attr_reader :name # Token
      attr_reader :params # Array<Token>
      attr_reader :body # Array<Stmt>
      
      def initialize(name, params, body)
        @name = name
        @params = params
        @body = body
      end
      
      def accept(visitor)
        visitor.visit_function_stmt(self)
      end
    end
    
    class If < Stmt
      attr_reader :condition # Expr
      attr_reader :then_branch # Stmt
      attr_reader :else_branch # Stmt
      
      def initialize(condition, then_branch, else_branch)
        @condition = condition
        @then_branch = then_branch
        @else_branch = else_branch
      end
      
      def accept(visitor)
        visitor.visit_if_stmt(self)
      end
    end
    
    class Print < Stmt
      attr_reader :expression # Expr
      
      def initialize(expression)
        @expression = expression
      end
      
      def accept(visitor)
        visitor.visit_print_stmt(self)
      end
    end
    
    class Return < Stmt
      attr_reader :keyword # Token
      attr_reader :value # Expr
      
      def initialize(keyword, value)
        @keyword = keyword
        @value = value
      end
      
      def accept(visitor)
        visitor.visit_return_stmt(self)
      end
    end
    
    class Var < Stmt
      attr_reader :name # Token
      attr_reader :initializer # Expr
      
      def initialize(name, initializer)
        @name = name
        @initializer = initializer
      end
      
      def accept(visitor)
        visitor.visit_var_stmt(self)
      end
    end
    
    class While < Stmt
      attr_reader :condition # Expr
      attr_reader :body # Stmt
      
      def initialize(condition, body)
        @condition = condition
        @body = body
      end
      
      def accept(visitor)
        visitor.visit_while_stmt(self)
      end
    end
  end
end
