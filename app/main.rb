module Main
  def init args
    args.state.a = 0
    args.state.b = 0
    args.state.delay = 10
  end

  def tick args
    if args.state.tick_count == 0
      init args
    end

    args.state.delay -= 1

    if args.state.delay <= 0
      args.state.delay = 10

    end

    args.state.a -= 6
    if args.state.a < -360
      args.state.a += 360
      args.state.b -= 10
    end

    if args.state.b == args.state.a
      args.state.b = args.state.a
    end

    if args.state.b < -360
      args.state.b += 360
    end

    args.outputs.primitives << {x:640, y:360, w:200, h: 200,
                                anchor_x: 0.5, anchor_y: 0.5,
                                angle: args.state.b + 90,
                                path: "sprites/circle/blue.png"}
    args.outputs.primitives << {x:640, y:360, w:100, h: 100,
                                anchor_x: 0.5, anchor_y: 0.5,
                                angle: args.state.a + 90,
                                path: "sprites/circle/green.png"}
  end
end
