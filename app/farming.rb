module Main
  def init args
    args.state.world = []
    args.state.window = {}
    args.state.window.x = 0
    args.state.window.y = 0
    args.state.window.w = 1280
    args.state.window.h = 720

    args.outputs[:scene].w = 1280
    args.outputs[:scene].h = 720
  end

  # Farming Game?
  # Sprites, Tiles, map
  # Crop-growing - Corn, Wheat, Beans, Fruits?
  # Non-food crops - Flowers (Bees, Trade),
  # Some traking mechanic?
  # Other sources of stuff?
  # Hunting - Rabbits, Deer, Birds
  # Fishing - Fish.  A few types
  # Trading - Stuff and things
  # Foraging - Berries, Wild veggies, Honey, Wild fruits
  # Trees - Fruits, Nuts, Wood, Beehives (Honey)
  # Beehives (recurring honey)


  # Map: grid + Render-Target
  # World-size = 9 screens, or 96 x 54 tiles
  # Tile-size: 40x40 = 32 x 18 tile View
  # View: Window on the RT


  # Starting to think about the actual farm simulation
  # What do crops need?
  # PRepared Soil
  # Planted
  # Watered
  # Correct sun
  # Time
  # Harvest

  # Cycles
  # Year/Seasons
  # Month/Moon?
  # Day
  # Weather
  # Plant growth Cycles


  def render args
    args.outputs[:scene].primitives << {x:0, y:0, w:1280, h:720, r:128, g:128, b:128}.solid!
  end

  def tick args
    if args.state.tick_count == 0
      init args
    end

    render(args)

    args.outputs << {x:0, y:0, w:1280, h:720,
                     target_x: args.state.window.x,
                     target_y: args.state.window.y,
                     target_w: args.state.window.w,
                     target_h: args.state.window.h,
                     path: :scene}
  end
end
