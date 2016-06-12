class DayUnit
  attr_reader :date, :units_num
  attr_accessor :shift

  def initialize date, ws_num
    @date = date
    @units_num = ws_num
    @shift = -1 
  end
end

