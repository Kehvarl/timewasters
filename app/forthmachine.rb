module Main
  def init args
    args.state.machine = Machine.new()
  end

  def tick args
    if args.state.tick_count == 0
      init args
    end

    args.state.machine.tick()
  end



  class Machine
    attr_reader :cpu, :memory

    def initialize
      @cpu = CPU.new()
      @mem_size = 65536
      @memory = Memory.new(@mem_size)
    end

    def tick
      # Fetch next instruction
      inst = @memory.read(@cpu.ip)

      # Decode instruction
      # Execute instruction

      @memory.write(@cpu.ip, inst + 1)
      puts "#{@cpu.ip}:#{inst}"

      # increment IP
      @cpu.ip = (@cpu.ip + 1) % @mem_size
    end

  end

  class CPU
    attr_accessor :ip

    CELL_BITS = 16
    CELL_SIZE = CELL_BITS / 8
    CELL_MASK = (1 << CELL_BITS) - 1

    def initialize
      @data_stack = []
      @return_stack = []
      @ip = 0
    end

    # Data Stack Tools
    def normalize(value)
      value & CELL_MASK
    end

    def push(value)
      @data_stack << normalize(value)
    end

    def pop
      return @data_stack.pop
    end

    def swap
      # n1 n2 -- n2 n1
      if @data_stack.length >= 2
        temp = @data_stack[-1]
        temp2 = @data_stack[-2]
        @data_stack[-2] = temp
        @data_stack[-1] = temp2
      end
    end

    def dup
      # n -- n n
      if @data_stack.length > 0
        push(@data_stack[-1])
      end
    end

    def over
      # n1 n2 -- n1 n2 n1
      if @data_stack.length >= 2
        push(@data_stack[-2])
      end
    end

    def drop
      # n1 --
      if @data_stack.length >= 1
        pop()
      end
    end

    # Return Stack Tools
    def to_r
      if @data_stack.length > 0
        @return_stack << @data_stack.pop()
      end
    end

    def from_r
      if @return_stack.length > 0
        @data_stack << @return_stack.pop()
      end
    end

    def fetch_r
      if @return_stack.length > 0
        @data_stack << @return_stack.last()
      end
    end

    # ALU

    def add
      # n1 n2 -- (n2 + n1)
      push(pop() + pop())
    end

    def sub
      # n1 n2 -- (n2 - n1)
      right = pop()
      left = pop()
      push(left - right)
    end
  end

  class Memory
    def initialize(size)
      @memory = Array.new(size, 0)
    end

    def read(address)
      @memory[address]
    end

    def write(address, value)
      @memory[address] = value
    end
  end
end
