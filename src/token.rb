module RbLox
  class Token
    attr_reader :type
    attr_reader :lexeme
    attr_reader :literal
    attr_reader :line

    def initialize(type, lexeme, literal, line)
      @type = type
      @lexeme = lexeme
      @literal = literal
      @line = line
    end

    def to_s
      # This should emulate the toString() method of the original code.
      # For a more idiomatic version, either call token.inspect()
      # or implement to_s as follows:
      #   "#{type} #{lexeme} #{literal}"
      "#{type.to_s.upcase} #{lexeme} #{literal}"
    end
  end
end
