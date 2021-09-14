module RbLox
  class Expr
    # For the definition of Expr::Visitor, see the "visitors" file.
    class Visitor
      def visit_assign_expr(expr) end

      def visit_binary_expr(expr) end

      def visit_call_expr(expr) end

      def visit_get_expr(expr) end

      def visit_grouping_expr(expr) end

      def visit_literal_expr(expr) end

      def visit_logical_expr(expr) end

      def visit_set_expr(expr) end

      def visit_super_expr(expr) end

      def visit_this_expr(expr) end

      def visit_unary_expr(expr) end

      def visit_variable_expr(expr) end
    end

    class Assign < Expr
      attr_reader :name # Token
      attr_reader :value # Expr

      def initialize(name, value)
        @name = name
        @value = value
      end

      def accept(visitor)
        visitor.visit_assign_expr(self)
      end
    end

    class Binary < Expr
      attr_reader :left # Expr
      attr_reader :operator # Token
      attr_reader :right # Expr

      def initialize(left, operator, right)
        @left = left
        @operator = operator
        @right = right
      end

      def accept(visitor)
        visitor.visit_binary_expr(self)
      end
    end

    class Call < Expr
      attr_reader :callee # Expr
      attr_reader :paren # Token
      attr_reader :arguments # Array<Expr>

      def initialize(callee, paren, arguments)
        @callee = callee
        @paren = paren
        @arguments = arguments
      end

      def accept(visitor)
        visitor.visit_call_expr(self)
      end
    end

    class Get < Expr
      attr_reader :object # Expr
      attr_reader :name # Token

      def initialize(object, name)
        @object = object
        @name = name
      end

      def accept(visitor)
        visitor.visit_get_expr(self)
      end
    end

    class Grouping < Expr
      attr_reader :expression # Expr

      def initialize(expression)
        @expression = expression
      end

      def accept(visitor)
        visitor.visit_grouping_expr(self)
      end
    end

    class Literal < Expr
      attr_reader :value # Object

      def initialize(value)
        @value = value
      end

      def accept(visitor)
        visitor.visit_literal_expr(self)
      end
    end

    class Logical < Expr
      attr_reader :left # Expr
      attr_reader :operator # Token
      attr_reader :right # Expr

      def initialize(left, operator, right)
        @left = left
        @operator = operator
        @right = right
      end

      def accept(visitor)
        visitor.visit_logical_expr(self)
      end
    end

    class Set < Expr
      attr_reader :object # Expr
      attr_reader :name # Token
      attr_reader :value # Expr

      def initialize(object, name, value)
        @object = object
        @name = name
        @value = value
      end

      def accept(visitor)
        visitor.visit_set_expr(self)
      end
    end

    class Super < Expr
      attr_reader :keyword # Token
      attr_reader :method # Token

      def initialize(keyword, method)
        @keyword = keyword
        @method = method
      end

      def accept(visitor)
        visitor.visit_super_expr(self)
      end
    end

    class This < Expr
      attr_reader :keyword # 

      def initialize(keyword)
        @keyword = keyword
      end

      def accept(visitor)
        visitor.visit_this_expr(self)
      end
    end

    class Unary < Expr
      attr_reader :operator # Token
      attr_reader :right # Expr

      def initialize(operator, right)
        @operator = operator
        @right = right
      end

      def accept(visitor)
        visitor.visit_unary_expr(self)
      end
    end

    class Variable < Expr
      attr_reader :name # Token

      def initialize(name)
        @name = name
      end

      def accept(visitor)
        visitor.visit_variable_expr(self)
      end
    end
  end
end
