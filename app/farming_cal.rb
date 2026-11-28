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

    def update_moon_sprite calendar
      moon = calc_moon_status(calendar)

      unless moon.moon_visible
        calendar.displayed_moon_day = calendar.moon_day
      end
    end

    def moon_times moon_day
      minutes = (moon_day % 28) * (1440.0 / 28)

      rise_abs = (360 + minutes).to_i % 1440
      set_abs = (rise_abs + 720) % 1440

      rise_hour = rise_abs.div(60)
      rise_minute = rise_abs % 60

      set_hour = set_abs.div(60)
      set_minute = set_abs % 60

      [rise_hour, rise_minute, set_hour, set_minute, rise_abs, set_abs]
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
      args.outputs <<{x:1080, y:690, text: "%04d-%02d-%02d %02d:%02d" % [
                                            cal.year, cal.month,
                                            cal.day, cal.hour, cal.minute]
                     }.label!

      moon = calc_moon_status(cal)
      if moon.moon_visible
        sprite_day = cal.displayed_moon_day

        source_x = (sprite_day % 7) * 128
        source_y = (3 - sprite_day.div(7)) * 128
        args.outputs << {x:1040, y:630, w:32, h:32,
                         source_x: source_x,
                         source_y: source_y,
                         source_w: 128,
                         source_h: 128,
                         path: "sprites/moon-phases.png"}
      end
      args.outputs <<{x:1080, y:655,
                     text:"#{moon.moon_day} :: #{moon.rise_hour}:#{moon.rise_minute} - #{moon.set_hour}:#{moon.set_minute}"
                    }.label!
    end
end
