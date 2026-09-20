module Main
  def init args

  end

  def tick args
    if args.state.tick_count == 0
      init args
    end

    args.outputs.primitives << {x:0, y:0, w:1280, h:720, r:128, g:128, b:128}.solid!
    args.outputs.primitives << {x:110, y:90, w:1080, h:520, r:96, g:96, b:96}.solid!
    args.outputs.primitives << {x:100, y:100, w:1080, h:520, r:192, g:192, b:192}.solid!
  end
end
