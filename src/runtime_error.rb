module RbLox
  # This class was called RuntimeError in JLox and extended RuntimeException.
  # In Ruby, RuntimeError is an existing class, so
  # LoxRuntimeError seemed like the next best option.
  class LoxRuntimeError < RuntimeError
    attr_reader :token

    def initialize(token, message)
      super message
      @token = token
    end
  end
end
