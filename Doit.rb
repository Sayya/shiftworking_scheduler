module Doit
  def apply plan
    init_date plan["date"]

    plan["unit"].each do |ws, persons|
      persons.each do |candid|
        @table[candid][:shiftline].line[plan["date"]].shift = ws unless candid == nil
      end
    end
    @table.each do |person, val|
      val[:shiftline].line[plan["date"]].shift = 0 if val[:shiftline].line[plan["date"]].shift == -1
    end

    self.changed
  end

  def init_date date
    @table.each do |person,val|
      val[:shiftline].line[date].shift = -1
    end
  end
end
