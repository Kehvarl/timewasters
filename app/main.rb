module Main
  def init args
    args.state.delay_current=10
    args.state.delay=10

    args.state.iterations = 0
    args.state.grid = make_map(128, 128)
  end

  def make_map height, width
    new_grid = Array.new(height) { Array.new(width, 0) }
    new_grid.each_with_index do |row, row_i|
      row.each_with_index do |col, col_i|
        if rand(100) <= 65
          new_grid[row_i][col_i] = 1
        end
      end
    end
    return new_grid
  end

  def neighbor_count grid, row, col
    neighbors = 0
    [-1, 0, 1].each do |r|
      y = (row + r) % grid.length()
      [-1, 0, 1].each do |c|
        if r == 0 and c == 0
          next
        else
          x = (col + c) % grid[0].length()
          if grid[y][x] == 1
            neighbors += 1
          end
        end
      end
    end
    return neighbors
  end

  def process_grid grid, keep=[4,5]
    new_grid = Array.new(grid.length) { Array.new(grid[0].length, 0) }
    grid.each_with_index do |row, row_i|
      row.each_with_index do |col, col_i|
        if col == 1
          neighbors = neighbor_count(grid, row_i, col_i)
          if keep.include?(neighbors)
            new_grid[row_i][col_i] = 1
          end
        else
          new_grid[row_i][col_i] = 0
        end
      end
    end
    return new_grid
  end

  def find_regions grid
    scanned = []
    regions = {0:[]}
    current_region = 0
    # for cell in grid
    #  if cell in scanned, continue
    #  if cell is wall, continue
    #  Start flood-fill from cell
    #   Find all connected non-wall, non-scanned cells
    #   add cell to current region
    #   add cell to scanned
    #  increment current region
    # result: list of regions and all cells in each region
    #  Maybe we should make the cells encode both wall/empty and region for faster lookup
  end

  def handle_input args

    if args.inputs.keyboard.key_down.r
      args.state.grid = make_map(128, 128)
      args.state.iterations = 0
      args.state.delay_current = args.state.delay
    end

    if args.inputs.keyboard.key_down.s
      args.state.grid = process_grid(args.state.grid)
    end
  end

  def render args
    out = []
    size = 720.div(args.state.grid.length)
    y = 690-size
    args.state.grid.each do |row|
      row.each_with_index do |v, i|
        if v == 1
          out << {x:i*size+280, y:y, w:size, h:size, path:'sprites/hexagon/green.png'}.sprite!
        end
      end
      y -= size
    end
    out
  end

  def tick args
    if args.state.tick_count == 0
      init args
    end

    handle_input(args)

    args.state.delay_current -= 1
    if args.state.delay_current <= 0
      args.state.delay_current = args.state.delay

      if args.state.iterations > 0
        args.state.grid = process_grid(args.state.grid)
        args.state.iterations -= 1
      end

    end

    args.outputs.primitives << render(args)
  end

end
