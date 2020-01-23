require_relative './environment.rb'
require_relative './lox_callable.rb'

###############
# TODO        #
###############

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
      expr.accept(this)
    end
    
    # expr : Expr
    # depth : Int
    def resolve(expr, depth)
      locals[expr] = depth
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
        self.environment = previous
      end
      nil
    end
    
    def visit_block_stmt(stmt)
      execute_block stmt.statements, Environment.new(@environment)
    end
  end
 end
