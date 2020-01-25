require_relative './token.rb'

module RbLox
  class Scanner
  
    # This part looks ugly because String literals 
    # in Ruby are mutable. The call to .freeze makes them
    # immutable.
    # They can be left to be mutable and never changed, but 
    # freezing them can actually speed up the application.
    # Capitalizing @@Keywords makes the variable final and
    # the call to .freeze makes the Hash immutable.
    @@Keywords = {
      'and'.freeze => :and,
      'class'.freeze => :class,
      'else'.freeze => :else,
      'false'.freeze => :false,
      'for'.freeze => :for,
      'fun'.freeze => :fun,
      'if'.freeze => :if,
      'nil'.freeze => :nil,
      'or'.freeze => :or,
      'print'.freeze => :print,
      'return'.freeze => :return,
      'super'.freeze => :super,
      'this'.freeze => :this,
      'true'.freeze => :true,
      'var'.freeze => :var,
      'while'.freeze => :while
    }.freeze
    
    attr_reader :source
    attr_reader :tokens
    
    def initialize(source)
      @source = source
      @tokens = []
      
      @start = 0
      @current = 0
      @line = 1
    end
    
    def scan_tokens
      until is_at_end?
        @start = @current
        scan_token()
      end
      
      @tokens << Token.new(:eof, '', nil, @line)
      @tokens
    end
    
    def scan_token
      c = advance()
      
      case c
      when '('
        add_token(:left_paren)
      when ')'
        add_token(:right_paren)
      when '{'
        add_token(:left_brace)
      when '}'
        add_token(:right_brace)
      when ','
        add_token :comma
      when '.'
        add_token :dot
      when '-'
        add_token :minus
      when '+'
        add_token :plus
      when ';'
        add_token :semicolon
      when '*'
        add_token :star
      when '!'
        add_token(match('=') ? :bang_equal : :bang)
      when '='
        add_token(match('=') ? :equal_equal : :equal)
      when '<'
        add_token(match('=') ? :less_equal : :less)
      when '>'
        add_token(match('=') ? :greater_equal : :greater)
      when '/'
        if match('/')
          advance() while (peek() != "\n" && !is_at_end?)
        else
          add_token :slash
        end
      when ' ', "\r", "\t"
        # ignore
      when "\n"
        @line += 1
      when '"'
        string()
      else
        if is_digit?(c)
          number()
        elsif is_alpha?(c)
          identifier()
        else
          Lox.error @line, 'Unexpected character.'
        end
      end
    end
    
    def identifier
      advance() while is_alpha_numeric?(peek())
      
      text = source[@start...@current]
      
      # Get from keywords, use :identifier as default.
      # Alternative:
      #   type = @@Keywords[text]
      #   type = :identifier if type.nil?
      type = @@Keywords.fetch(text, :identifier)
      
      add_token type
    end
    
    def number
      advance() while is_digit?(peek())
      
      if (peek() == '.' && is_digit?(peek_next()))
        advance() # Consume the dot '.'
        advance() while is_digit?(peek())
      end
      
      add_token :number, @source[@start...@current].to_f
    end
    
    def string
      while (peek() != '"' && !is_at_end?)
        line += 1 if (peek() == "\n")
        advance()
      end
      
      if is_at_end?
        Lox.error line, 'Unterminated string.'
        return
      end
      
      # Consume closing '"'
      advance()
      
      # Trim surrounding quotes
      value = source[(@start + 1)...(@current - 1)]
      add_token :string, value
    end
    
    # Could be called 'match?', but I decided not to because it takes
    # an argument. Both are valid though.
    def match(expected)
      return false if is_at_end?
      return false unless @source[@current] == expected
      
      @current += 1
      true
    end
    
    def peek
      # Get source at current index.
      # If is out of bounds (returns nil), return "\0"
      @source[@current] || "\0"
    end
    
    def peek_next
      # Get source at current index + 1.
      # If is out of bounds (returns nil), return "\0"
      @source[@current + 1] # return char at @current+1 or nil
    end
    
    # is_alpha?, is_alpha_numeric? and is_digit?
    # These can be done as a direct conversion or insert a new method
    # into the build-in String class.
    # I decided to use Rubys Regex literals just to show them.
    # A big difference is that these Regex literals work on Unicode 
    # characters too. If you do not want this, use the ascii-only versions
    # (which I commented out).
    # 
    # See https://stackoverflow.com/questions/10637606/doesnt-ruby-have-isalpha
    # for an interesting read on the topic.
    # On rubydoc: https://ruby-doc.org/core-2.7.0/Regexp.html
    # Alternative versions were added as comments.
    
    def is_alpha?(c)
      # Match alpha character and make bool (via double negation !!)
      c && !!c.match(/^[[:alpha:]]$/)
      
      # !!c.match(/[a-zA-Z0-9]/)
    end
    
    def is_alpha_numeric?(c)
      # Match alpha-numeric character and make bool (via double negation !!)
      c && !!c.match(/^[[:alnum:]]$/)
      
      # !!c.match(/[a-zA-Z0-9]/)
    end
    
    def is_digit?(c)
      # Match single digit character and make bool (via double negation !!)
      c && !!c.match(/^\d$/)
      
      # !!c.match(/[0-9]/)
    end
    
    def is_at_end?
      @current >= @source.size
    end
    
    def advance
      @current += 1
      @source[@current - 1]
    end
    
    def add_token(type, literal = nil)
      text = @source[@start...@current]
      tokens << Token.new(type, text, literal, @line)
    end
  end
end
