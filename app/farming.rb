module Main
  def init args
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

  def tick args
    if args.state.tick_count == 0
      init args
    end
  end
end
