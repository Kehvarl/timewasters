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
    args.state.tunnes = {}
    args.state.delay_current = args.state.delay
  end

  def make_map height, width
    new_grid = Array.new(height) { Array.new(width, -2) }
    new_grid.each_with_index do |row, row_i|
      row.each_with_index do |col, col_i|
        if rand(100) <= 50
          new_grid[row_i][col_i] = -1
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
          if grid[y][x] > -2
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
      row.each_with_index do |cell, col_i|
        neighbors = neighbor_count(grid, row_i, col_i)
        if neighbors >= create
          new_grid[row_i][col_i] = -1
        elsif neighbors == keep
          new_grid[row_i][col_i] = cell
        else
          new_grid[row_i][col_i] = -2
        end
      end
    end
    return new_grid
  end

  def invert_grid grid
    new_grid = Array.new(grid.length) { Array.new(grid[0].length, 0) }
    grid.each_with_index do |row, row_i|
      row.each_with_index do |cell, col_i|
        if cell == -2
          new_grid[row_i][col_i] = -1
        else
          new_grid[row_i][col_i] = -2
        end
      end
    end
    return new_grid
  end

  def flood_fill grid, start, id
    rows = grid.length
    cols = grid[0].length

    region = []
    queue = [start]
    grid[start[0]][start[1]] = id

    while queue.length  > 0
      row, col = queue.pop
      region << [row, col]
      neighbors = [[row - 1, col],[row + 1, col],[row, col - 1],[row, col + 1]]
      neighbors.each do |pos|
        r, c = pos
        if r < 0 || r >= rows || c < 0 || c >= cols
          next
        end
        if grid[r][c] != -1
          next
        end

        grid[r][c] = id
        queue << pos
      end
    end

    region
  end

  def find_regions grid
    rows = grid.length
    cols = grid[0].length
    regions = {}
    current_region = 0
    # for cell in grid
    grid.each_with_index do |row, row_i|
      row.each_with_index do |cell, col_i|
        pos = [row_i, col_i]
        if cell != -1
          next
        end
        regions[current_region] = flood_fill(grid, pos, current_region)
        current_region +=  1
      end
    end
    return regions
  end

  def carve_horizontal_tunnel grid, start_pos, end_pos, tunnel
    regions = []
    sy, sx = start_pos
    ey, ex = end_pos

    ([sx, ex].min() .. [sx, ex].max).each do |x|
      if args.state.grid[sy][x] > -2
        if args.state.grid[y][sx] > -1
          regions << args.state.grid[y][sx]
        end
        tunnel << [sy, x]
      end
    end

    return tunnel, regions
  end

  def carve_vertical_tunnel grid, start_pos, end_pos, tunnel
    regions = []
    sy, sx = start_pos
    ey, ex = end_pos

    ([sy, ey].min() .. [sy, ey].max).each do |y|
      if args.state.grid[y][sx] > -2
        if args.state.grid[y][sx] > -1
          regions << args.state.grid[y][sx]
        end
        tunnel << [sy, x]
      end
    end

    return tunnel, regions
  end

  def carve_tunnel_hv grid, start_pos, end_pos, regions
    regions = []
    tunnel, region = carve_horizontal_tunnel(grid, start_pos, end_pos, region)
    regions.extend(region)
    cur = [start_pos[0], end_pos[1]]
    tunnel, region = carve_vertical_tunnel(grid, cur, end_pos, region)
    regions.extend(region)
    return tunnel, regions
  end

  def carve_tunnel_vh grid, start_pos, end_pos, regions
    regions = []
    tunnel, region = carve_vertical_tunnel(grid, start_pos, end_pos, region)
    regions.extend(region)
    cur = [start_pos[1], end_pos[0]]
    tunnel, region = carve_horizontal_tunnel(grid, cur, end_pos, region)
    regions.extend(region)
    return tunnel, regions
  end

  def carve_tunnels grid, regions
    unused_regions = regions.keys
    tunnels = {}
    tunnel = 0
    # Select region pair,
    # get start_pos from region_1
    # get end_pos from region_2
    tunnels, tunnel_regions = carve_tunnel(grid, start_pos, end_pos, regions)
    unused_regions = unused_regions - tunnel_regions

    tunnels.each do |t|
      tunels[tunnel] = t
      tunnel += 1
    end

    return tunnels
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
      args.state.tunnels = carve_tunnels(args.state.grid, args.state.regions)
    end
  end

  def render args
    out = []
    size = 720.div(args.state.grid.length)
    y = 690-size
    args.state.grid.each do |row|
      row.each_with_index do |v, i|
        if v == -2
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
