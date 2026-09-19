module Main
  def init args

  end

  def tick args
    if args.state.tick_count == 0
      init args
    end

    args.outputs.primitives << {x:0, y:0, w:1280, h:720, r:128, g:128, b:128}.solid!
  end
end
