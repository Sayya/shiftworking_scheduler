class Month
  attr_reader :year, :mon_name
  attr_reader :start_day, :days_num

  @@calender = {"Jan" => 31, "Feb" => 28,
                "Mar" => 31, "Apr" => 30,
                "May" => 31, "Jun" => 30,
                "Jul" => 31, "Aug" => 31,
                "Sep" => 30, "Oct" => 31,
                "Nov" => 30, "Dec" => 31}

  def initialize year, mon_name
    @year = year
    @mon_name = mon_name
    @days_num = @@calender[mon_name]
    @days_num += 1 if mon_name == "Feb" && leap_year?
    @start_day = 'Sun'
  end

  def leap_year?
    if (@year.to_i % 4 == 0 && @year.to_i % 100 != 0) || @year.to_i % 400 == 0
      true
    else
      false
    end
  end
end

