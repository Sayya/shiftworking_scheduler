require './DayUnit.rb'

class ShiftLine
  attr_reader :line, :sum

  def initialize days_num, ws_num
    @line = Array.new(days_num) {|date| DayUnit.new(date, ws_num) }
    @sum = {on: 0, off: 0, minute: 0, ws: Array.new(ws_num, 0)}
  end
end
