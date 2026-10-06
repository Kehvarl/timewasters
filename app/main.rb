module Main
  def init args
    args.state.lines = []
    args.state.delay_current=10
    args.state.delay=10
  end

  def randomline size=63
    newline = []
    size.times do
      newline << [0,1].sample()
    end
    return newline
  end

  def face size=63
    newline = Array.new(size, 0)
    midpoint = size.div(2)
    newline[midpoint - 3] = 1
    newline[midpoint - 2] = 1
    newline[midpoint - 1] = 1
    newline[midpoint + 1] = 1
    newline[midpoint + 2] = 1
    newline[midpoint + 3] = 1
    return newline
  end

  def glider size=63
    newline = Array.new(size, 0)
    midpoint = size.div(2)
    newline[midpoint - 3] = 1
    newline[midpoint - 1] = 1
    newline[midpoint]     = 1
    newline[midpoint + 1] = 1
    return newline
  end

  def next_line line, radius=2, born=[2,3], survive=[2,4]
    newline = Array.new(line.length, 0)
    line.each_with_index do |v, i|
      neighbors = 0
      (-radius..radius).each do |r|
        if r != 0
          if line[(i - r) % line.length] > 0
            neighbors += 1
          end
        end
      end
      if v == 0 and born.include?(neighbors)
        newline[i] = 1
      elsif v == 1 or v == 2 and survive.include?(neighbors)
        newline[i] = 2
      end
    end
    return newline
  end

  def render args
    out = []
    y = 700
    args.state.lines.last(36).each do |line|
      if line
        line.each_with_index do |v, i|
          if v == 1
            out << {x:i*20, y:y, w:20, h:20, path:'sprites/hexagon/green.png'}.sprite!
          elsif v == 2
            out << {x:i*20, y:y, w:20, h:20, path:'sprites/hexagon/blue.png'}.sprite!
          end
        end
        y -= 20
      end
    end
    out
  end

  def tick args
    if args.state.tick_count == 0
      init args
      args.state.lines << randomline()
    end

    if args.inputs.mouse.click
      args.state.lines << randomline()
      args.state.delay_current = args.state.delay
    end

    if args.inputs.keyboard.key_down.f
      args.state.lines << face()
      args.state.delay_current = args.state.delay
    end

    if args.inputs.keyboard.key_down.g
      args.state.lines << glider()
      args.state.delay_current = args.state.delay
    end

    args.state.delay_current -= 1
    if args.state.delay_current <= 0
      args.state.lines << next_line(args.state.lines.last())
      args.state.delay_current = args.state.delay
    end

    args.outputs.primitives << render(args)
  end

end
