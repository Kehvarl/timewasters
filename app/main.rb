module Main
  def init args
    args.state.outs = []
  end

  def tick args
    if args.state.tick_count == 0
      init args
    end

    if rand(1000) < 1000
      w = rand(500) + 50
      h = rand(300) + 50
      x = rand(1280 - w)
      y = rand(720 - h)
      #r = [0, 45, 90, 135, 180, 225, 270].sample
      r = rand(360)

      args.state.outs << {x:x, y:y, w:w, h:w, angle:r,
                          path:'sprites/square/white.png',
                          r:rand(128) + 64, g:rand(128) + 64, b:rand(128) + 64}.sprite!
    end

    args.outputs.primitives << {x:0, y:0, w:1280, h:720, r:128, g:128, b:128}.solid!
    args.outputs.primitives << {x:110, y:90, w:1080, h:520, r:96, g:96, b:96}.solid!
    args.outputs.primitives << {x:90, y:110, w:1080, h:520, r:224, g:224, b:224}.solid!
    args.outputs.primitives << {x:100, y:100, w:1080, h:520, r:192, g:192, b:192}.solid!

    args.outputs.primitives << args.state.outs
  end
end
