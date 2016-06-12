require './ShiftTable.rb'
require './Checker.rb'

class Main_Scheduler
  def process
    @c = Checker.new
    @t = ShiftTable.new
    @c.set_shift @t
    @t.month.days_num.times do |num|
      @t.apply @c.planning_date(num)
    end
  end
  
  def process_for num
    trying = 0
    until @c.total_avg_check || trying >= num
      @t = ShiftTable.new
      @c.set_shift @t
      @t.month.days_num.times do |num|
        @t.apply @c.planning_date(num)
      end
      trying += 1
      print '-' 
      puts if trying % 100 == 0
    end
  end

  def debug_conditions
    @t.view
    p @c.total_avg_check
    p @t.ws
    p @c.rule
    @t.table.each {|key, val| p val[:condition]}
  end
end

m = Main_Scheduler.new
m.process
#m.process_for 300
m.debug_conditions
