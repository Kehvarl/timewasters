module Main

    LUNAR_CYCLE_DAYS = 28
    DAY_MINUTES = 1440

    def update_calendar calendar
      calendar.total_minutes += 1

      total = calendar.total_minutes

      calendar.minute = total % 60
      calendar.hour = (total / 60).to_i % 24

      total_days = (total / (60 * 24)).to_i

      calendar.day = (total_days % 36) + 1
      calendar.month = (total_days.div(36) % 12) + 1
      calendar.year = total_days.div(432) + 1

      calendar.season = case calendar.month
         when 1..3 then :spring
         when 4..6 then :summer
         when 7..9 then :autumn
         when 10..12 then :winter
      end

      calendar.next_moon_day = total_days % 28
    end

    def moon_times moon
      minutes = (moon.moon_day % 28) * (1440.0 / 28)

      rise_hour = (6 + minutes.div(60)) % 24
      rise_minute = (minutes % 60).to_i

      rise_abs = (360 + minutes).to_i % 1440
      set_abs = (rise_abs + 720) % 1440

      set_time = (rise_hour * 60 + rise_minute + 720) % 1440

      [rise_hour, rise_minute, set_time.div(60), set_time % 60, rise_abs, set_abs]
    end

    def calc_moon_status calendar
      total_minutes = calendar.total_minutes

      # Continuous lunar phase: 0.0 through just under 28.0
      phase = (total_minutes.to_f / DAY_MINUTES) % LUNAR_CYCLE_DAYS

      # Discrete sprite index, transitions halfway between phases
      moon_day = (phase + 0.5).floor % LUNAR_CYCLE_DAYS

      rise_abs = (360 + phase.to_i * DAY_MINUTES / LUNAR_CYCLE_DAYS).to_i % DAY_MINUTES
      set_abs = (rise_abs + 720) % DAY_MINUTES

      current_minutes = calendar.hour * 60 + calendar.minute

      if rise_abs < set_abs
        moon_visible = current_minutes >= rise_abs && current_minutes < set_abs
      else
        moon_visible = current_minutes >= rise_abs || current_minutes < set_abs
      end

      {
        moon_visible: moon_visible,
        moon_day: moon_day,
        phase: phase,
        rise_abs: rise_abs,
        set_abs: set_abs,
        rise_hour: rise_abs / 60,
        rise_minute: rise_abs % 60,
        set_hour: set_abs / 60,
        set_minute: set_abs % 60
      }
    end

    def render_cal args
      cal = args.state.calendar
      args.outputs <<{x:600, y:350,
                      text:"#{cal.year}-#{cal.month}-#{cal.day} #{cal.hour}:#{cal.minute}"
                     }.label!

      moon = calc_moon_status(cal)
      if moon.moon_visible
        source_x = (moon.moon_day % 7) * 128
        source_y = (3 - moon.moon_day.div(7)) * 128
        args.outputs << {x:600, y:290, w:32, h:32,
                         source_x: source_x,
                         source_y: source_y,
                         source_w: 128,
                         source_h: 128,
                         path: "sprites/moon-phases.png"}
      end
      args.outputs <<{x:640, y:315,
                     text:"#{moon.moon_day} :: #{moon.rise_hour}:#{moon.rise_minute} - #{moon.set_hour}:#{moon.set_minute}"
                    }.label!
    end
end
