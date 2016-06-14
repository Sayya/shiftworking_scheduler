class Condition 
  attr_reader :pow, :percent, :date

  def initialize pow, d
    @pow = pow
    @date = d
  end
end

