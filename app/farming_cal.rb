module Main

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

      calendar.moon_day = total_days % 28
    end

    def moon_times moon_day
      minutes = (moon_day % 28) * (1440.0 / 28)

      rise_hour = (6 + minutes.div(60)) % 24
      rise_minute = (minutes % 60).to_i

      rise_abs = (360 + minutes).to_i % 1440
      set_abs = (rise_abs + 720) % 1440

      set_time = (rise_hour * 60 + rise_minute + 720) % 1440

      [rise_hour, rise_minute, set_time.div(60), set_time % 60, rise_abs, set_abs]
    end

    def calc_moon_status calendar
      moon_day = calendar.moon_day
      mrh, mrm, msh, msm, mra, msa = moon_times(moon_day)

      current_minutes = (calendar.hour * 60 + calendar.minute)

      if mra < msa
        moon_visible = current_minutes >= mra && current_minutes < msa
      else
        moon_visible = current_minutes >= mra || current_minutes < msa
      end
      #puts "#{cal.hour}, #{cal.minute} = #{current_minutes} -- #{mra} - #{msa} :: #{moon_visible}"
      return {moon_visible:moon_visible,
              moon_day:moon_day,
              rise_hour:mrh, rise_minute:mrm, rise_abs:mra,
              set_hour:msh, set_minute:msm, set_abs:msa}
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
