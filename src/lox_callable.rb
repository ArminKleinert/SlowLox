module RbLox
  # With this class, I really went far from the original...
  # 
  # Instead of being an interface,
  # LoxCallable has a callable member here.
  # This member can be passed as a block.
  # Sadly, the arity has to be passed manually.
  # Initializing a new instance works as follows:
  #   LoxCallable.new(arity, &block)
  # Eg.
  #   LoxCallable.new(3) {|interpr, *args| puts(Time.now)}
  # This example takes 3 arguments plus the interpreter.
  #
  # Consider taking a look at
  # https://ruby-doc.org/core-2.7.0/Proc.html
  # and
  # https://ruby-doc.org/core-2.7.0/Kernel.html#method-i-proc
  class LoxCallable
    attr_reader :name
    attr_reader :arity

    # Example:
    # LoxCallable.new("name", 1) { |interpreter, args| ... }
    def initialize(name="<native fn>", arity=0, &block)
      @name = name
      @arity = arity
      @proc = block
    end

    def call(interpreter, arguments)
      @proc.call(interpreter, *arguments)
    end
    
    def to_s
      @name
    end
  end
  
  # A shortcut for the construtor of LoxCallable:
  # RbLox.loxc(arity, &block)
  def self.loxc(arity=0, &block)
    LoxCallable.new(arity, &block)
  end
end
