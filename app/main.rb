module Main
  def init args
    args.state.delay_current=10
    args.state.delay=10

    restart(args)
  end

  def restart args
    args.state.grid = make_map(64, 64)
    args.state.iterations = 0
    args.state.regions = {}
    args.state.delay_current = args.state.delay
  end

  def make_map height, width
    new_grid = Array.new(height) { Array.new(width, 0) }
    new_grid.each_with_index do |row, row_i|
      row.each_with_index do |col, col_i|
        if rand(100) <= 55
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

  def process_grid grid, keep=4, create=5
    new_grid = Array.new(grid.length) { Array.new(grid[0].length, 0) }
    grid.each_with_index do |row, row_i|
      row.each_with_index do |col, col_i|
        neighbors = neighbor_count(grid, row_i, col_i)
        if neighbors >= 5
          new_grid[row_i][col_i] = 1
        elsif neighbors == 4
          new_grid[row_i][col_i] = col
        else
          new_grid[row_i][col_i] = 0
        end
      end
    end
    return new_grid
  end

  def invert_grid grid
    new_grid = Array.new(grid.length) { Array.new(grid[0].length, 0) }
    grid.each_with_index do |row, row_i|
      row.each_with_index do |col, col_i|
        if col == 0
          new_grid[row_i][col_i] = 1
        else
          new_grid[row_i][col_i] = 0
        end
      end
    end
    return new_grid
  end

  def flood_fill grid, start, scanned
    rows = grid.length
    cols = grid[0].length

    region = []
    queue = [start]
    scanned[start[0]][start[1]] = true

    while queue.length  > 0
      row, col = queue.pop

      region << [row, col]

      neighbors = [
        [row - 1, col],
        [row + 1, col],
        [row, col - 1],
        [row, col + 1]
      ]

      neighbors.each do |pos|
        r, c = pos

        if r < 0 || r >= rows || c < 0 || c >= cols
          next
        end
        if grid[r][c] == 1
          next
        end
        if scanned[r][c]
          next
        end

        scanned[r][c] = true
        queue << pos
      end
    end

    region
  end

  def find_regions grid
    rows = grid.length
    cols = grid[0].length
    scanned = Array.new(rows) { Array.new(cols, false) }
    regions = {}
    current_region = 0
    # for cell in grid
    grid.each_with_index do |row, row_i|
      row.each_with_index do |col, col_i|
        pos = [row_i, col_i]
        if scanned[row_i][col_i]
          next
        end
        if col == 1
          next
        end
        regions[current_region] = flood_fill(grid, pos, scanned)
        current_region +=  1
      end
    end
    # result: list of regions and all cells in each region
    # Maybe we should make the cells encode both wall/empty and region for faster lookup
    return regions
  end

  def carve_horizontal_tunnel grid, start_pos, end_pos, region
    sy, sx = start_pos
    ey, ex = end_pos

    ([sx, ex].min() .. [sx, ex].max).each do |x|
      if args.state.grid[sy][x] == 0
        args.state.grid[sy][x] = 1
        region << [sy, x]
      end
    end

    return grid
  end

  def carve_vertical_tunnel grid, start_pos, end_pos, region
    sy, sx = start_pos
    ey, ex = end_pos

    ([sy, ey].min() .. [sy, ey].max).each do |y|
      if args.state.grid[y][sx] == 0
        args.state.grid[y][sx] = 1
        region << [sy, x]
      end
    end

    return grid
  end

  def carve_tunnel grid, start_pos, end_pos, regions
    region = []
    grid = carve_horizontal_tunnel(grid, start_pos, end_pos, region)
    cur = [start_pos[0], end_pos[1]]
    grid = carve_vertical_tunnel(grid, cur, end_pos, region)
    region_id = regions.length
    region[region_id] = region
    return grid
  end

  def carve_tunnels grid, regions
    # Select region pair,
    # get start_pos from region_1
    # get end_pos from region_2
    grid = carve_tunnel(grid, start_pos, end_pos, regions)

    return grid
  end

  def handle_input args

    if args.inputs.keyboard.key_down.r
      restart(args)
    end

    if args.inputs.keyboard.key_down.s
      args.state.grid = process_grid(args.state.grid)
    end

    if args.inputs.keyboard.key_down.i
      args.state.grid = invert_grid(args.state.grid)
    end

    if args.inputs.keyboard.key_down.m
      args.state.regions = find_regions(args.state.grid)
    end

    if args.inputs.keyboard.key_down.t
      args.state.grid = carve_tunnels(args.state.grid, args.state.regions)
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

    colors = ["black", "blue", "gray", "indigo", "orange", "red", "violet", "white", "yellow"]
    if args.state.regions != {}
      args.state.regions.each_with_index do |r, i|
        color = colors[(i % colors.length)]
        r[1].each do |cell|
          y, x = cell
          out << {x:x*size+280, y:690 - ((y+1)*size), w:size, h:size, path:"sprites/hexagon/#{color}.png"}.sprite!
        end
      end
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
