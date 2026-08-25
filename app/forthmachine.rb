module Main
  class CPU
    def initialize
      @data_stack = []
      @return_stack = []
    end

    # Data Stack Tools
    def push val
      @data_stack << val
    end

    def pop
      return @data_stack.pop
    end

    def swap
      if @data_stack.length >= 2
        temp = @data_stack[-1]
        temp2 = @data_stack[-2]
        @data_stack[-2] = temp
        @data_stack[-1] = temp2
      end
    end

    def dup
      if @data_stack.lengthle > 0
        push(@data_stack[-1])
      end
    end

    # Return Stack Tools
    def to_r
      @return_stack << @data_stack.pop()
    end

    def from_r
      @data_stack << @return_stack.pop()
    end

    def fetch_r
      @data_stack << @return_stack.last()
    end

    # ALU

    def add
      push(pop() + pop())
    end

    def sub
      right = pop()
      left = pop()
      push(left - right)
    end

  end
end
