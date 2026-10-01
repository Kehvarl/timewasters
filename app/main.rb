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

  def next_line line, radius=2, born=[2,3], survive=[2,4]
    newline = Array.new(line.length, 0)
    line.each_with_index do |v, i|
      neighbors = 0
      (-radius..radius).each do |r|
        if r != 0
          neighbors += line[(i - r) % line.length]
        end
      end
      if v == 0 and born.include?(neighbors)
        newline[i] = 1
      elsif v == 1 and survive.include?(neighbors)
        newline[i] = 1
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
            out << {x:i*20, y:y, w:20, h:20, path:'sprites/square/blue.png'}.sprite!
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
      #init args
      args.state.lines << randomline()
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
