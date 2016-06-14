require './ShiftTable.rb'
require './Checker.rb'

class Main_Scheduler
  def process_first
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
      print '-' if trying % 10 != 0 
      print '=' if trying % 10 == 0 
      puts if trying % 100 == 0
    end
    puts
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
m.process_first
m.process_for 50
m.debug_conditions
