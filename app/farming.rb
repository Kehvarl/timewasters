module Main
  def init args
    args.state.window = {x:0, y:0, w:1280, h:720}
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
  # Player Hunger
  # Player Energy
  # Actually, should there be 1 Energy type?
  # We could have Focus/Mental Energy for learning Stuff
  # And Energy/Tiredness for Doing stuff.

  def init_world args
    args.state.calendar = {
      year: 1,
      season: :spring,
      day: 1,
      hour: 6,
      minute: 0,

      total_minutes: 0,
    }

    args.state.world_map = Array.new(54) do
      Array.new(96) do
        {
          terrain: :grass,
          plant_id: nil,
          tree_id: nil,
          building_id: nil,
          pickups: [],
          fertility: 100
        }
      end
    end

    args.state.plants = {}
    args.state.trees = {}
    args.state.buildings = {}
  end

  def plant_prototype
    {
      x: 20,
      y: 15,
      type: :corn,
      planted_day: 12,
      growth: 0,
      growth_stages: 5,
      water: 50,
      soil_quality: 80,
      health: 100
    }
  end

  def tree_prototype
    {
      type: :oak,
      age: 120,
      health: 100,
      fruit: nil,
      wood: 80
    }
  end

  def building_prototype
    {
      type: :barn,
      x: 20,
      y: 15,
      w: 4,
      h: 3,
      condition: 100
    }
  end

  def update_calendar calendar
    calendar.total_minutes += 1

    total = calendar.total_minutes

    calendar.minute = total % 60
    calendar.hour = (total / 60) % 24

    total_days = total / (60 * 24)

    calendar.day = (total_days % 36) + 1
    calendar.month = ((total_days / 36) % 12) + 1
    calendar.year = (total_days / 432) + 1

    calendar.season = case calendar.month
       when 1..3 then :spring
       when 4..6 then :summer
       when 7..9 then :autumn
       when 10..12 then :winter
    end

    calendar.moon_day = total_days % 28
  end

  def update_world args
    update_calendar(args.state.calendar)
    # update_weather(args)
    # update_environment(args)

    # update_plants(args)
    # update_animals(args)
    # update_buildings(args)
    # update_animals(args)
  end

  def render args
    args.outputs[:scene].primitives << {x:0, y:0, w:1280, h:720, r:128, g:128, b:128}.solid!
  end

  def tick args
    if args.state.tick_count == 0
      init(args)
      init_world(args)
    end

    update_world(args)

    render(args)

    args.outputs << {x:0, y:0, w:1280, h:720,
                     target_x: args.state.window.x,
                     target_y: args.state.window.y,
                     target_w: args.state.window.w,
                     target_h: args.state.window.h,
                     path: :scene}
    cal = args.state.calendar
    args.outputs <<{x:600, y:350,
                    text:"#{cal.year.to_i} - #{cal.day.to_i} #{cal.hour.to_i}:#{cal.minute}"
                   }.label!

    args.outputs <<{x:600, y:315,
                    text:"#{cal.moon_day.to_i}"
                   }.label!
  end
end
