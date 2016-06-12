class Condition 
  attr_reader :percent, :date

  def initialize ws, d
    @percent = ws
    @date = d
  end
end

