require './ShiftTable.rb'
require './Checker.rb'

class Main_Scheduler
	attr_reader :better_plan
  
	def process_first
    c = Checker.new
    t = ShiftTable.new
    c.set_shift t

    @better_plan = { table: t, checker: c }
    debug_conditions

    t.month.days_num.times do |num|
      t.apply c.planning_date(num)
    end

    @better_plan = { table: t, checker: c }
  end
  
  def process_for num
    trying = 0
    until @better_plan[:checker].total_avg_check[0] || trying >= num
			c = Checker.new
      t = ShiftTable.new
      c.set_shift t
      t.month.days_num.times do |num|
        t.apply c.planning_date(num)
      end

			@better_plan = {table: t, checker: c } if @better_plan[:checker].total_avg_check[3] > c.total_avg_check[3]

      trying += 1
      print '-' if trying % 10 != 0 
      print '=' if trying % 10 == 0 
      puts if trying % 100 == 0
    end
    puts
  end

  def debug_conditions
    @better_plan[:table].view
    p @better_plan[:checker].total_avg_check
    p @better_plan[:table].ws
    p @better_plan[:checker].rule
    @better_plan[:table].table.each {|key, val| p val[:condition]}
  end
end

xtimes = ARGV[0].to_i

m = Main_Scheduler.new
m.process_first
m.process_for xtimes if xtimes > 0 
m.debug_conditions
