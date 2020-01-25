module RbLox
  class Return < RuntimeError # Extends Rubys RuntimeError
    attr_reader :value

    def initialize(value)
      @value = value
    end
  end
end
