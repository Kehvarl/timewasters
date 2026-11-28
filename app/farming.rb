require('app/farming_cal.rb')

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
    args.state.time_scale = 1

    args.state.calendar = {
      year: 1,
      season: :spring,
      day: 1,
      hour: 0,
      minute: 0,

      moon_day: 0,
      next_moon_day: 0,

      total_minutes: 0,
    }

    args.state.weather = {

    }

    args.state.environment = {
      sunlight: 0.8,
      temperature: 22
    }

    args.state.world_map = Array.new(54) do
      Array.new(96) do
        {
          terrain: :grass,
          plant_id: nil,
          tree_id: nil,
          building_id: nil,
          pickups: [],
          water: 50,
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
      water_consumption: 0.5,
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

  def update_plants args
    args.plants.each do |id, plant|
      tile = world_map[plant.y][plant.x]
      update_plant(plant, args.state.environment, tile)
    end
  end

  def update_plant plant, environment, tile
    if plant.health <= 0
      return
    end

    if not environment.temperature.between?(plant.min_temperature, plant.max_temperature)
      return
    end

    if tile.water <= 0
      return
    end

    if tile.fertility <= 0
      return
    end

    growth = plant.growth_rate

    growth *= environment.sunlight
    growth *= tile.fertility / 100.0

    plant.growth += growth
    tile.water -= plant.water_consumption
  end

  def update_trees args
    args.trees.each do |id, tree|
      tile = world_map[tree.y][tree.x]
      update_tree(tree, args.state.environment, tile)
    end
  end

  def update_tree tree, environment, tile
    if tree.health <= 0
      return
    end

    # Check for Changes
    # Age
    # Fruit
    # Growth (Size, Wood qty, etc)

  end

  def update_world args
    calendar = args.state.calendar

    #calendar.total_minutes += args.state.time_scale

    update_calendar(calendar)

    # Update hourly
    # update_weather(args)
    # update_environment(args)

    # Update Daily
    # update_plants(args)
    # update_trees(args)
    # update_animals(args)
    # update_buildings(args)
  end

  def update_render_target args
    args.outputs[:scene].primitives << {x:0, y:0, w:1280, h:720, r:128, g:128, b:128}.solid!

    args.state.world_map.each_with_index do |row, y|
      row.each_with_index do |tile, x|
        args.outputs[:scene].primitives << {x:x*40, y:680 - y*40, w:40, h:40, path:'sprites/square/green.png'}.sprite!
      end
    end
  end

  def render args
    args.outputs << {x:0, y:0, w:1280, h:720,
                     target_x: args.state.window.x,
                     target_y: args.state.window.y,
                     target_w: args.state.window.w,
                     target_h: args.state.window.h,
                     path: :scene}
    render_cal(args)
  end

  def tick args
    if args.state.tick_count == 0
      init(args)
      init_world(args)
    end

    update_world(args)

    update_render_target (args)

    render(args)
  end
end
