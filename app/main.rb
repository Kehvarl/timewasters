module Main
  def init args
    
  end

  def tick args
    if args.state.tick_count == 0
      init args
    end
  end
end
