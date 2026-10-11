module Main
  def init args
    args.state.delay_current=10
    args.state.delay=10
  end

  def handle_input args
  end

  def tick args
    if args.state.tick_count == 0
      init args
      args.state.lines << randomline()
    end

    handle_input(args)

    args.state.delay_current -= 1
    if args.state.delay_current <= 0
      args.state.delay_current = args.state.delay

      # Do frame
    end

    args.outputs.primitives << render(args)
  end

end
