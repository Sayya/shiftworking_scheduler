class Condition 
  attr_reader :pow, :percent, :date

  def initialize pow, ws_per, d
    @pow = pow
    @percent = ws_per
    @date = d
  end
end

