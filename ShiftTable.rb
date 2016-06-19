require './Condition.rb'
require './ShiftLine.rb'
require './Month.rb'
require './Doit.rb'

class ShiftTable
  include Doit
  attr_reader :month, :ws
  attr_accessor :table
  
  def initialize
    shift_txt = IO.read './shift.txt'
    config_txt = IO.read './config.txt'

    set_month shift_txt
    set_unit config_txt
    set_table shift_txt

    set_wish_to_table
  end

  def set_month shift_txt
    year = /^year\s*=\s*(\d{4})$/.match(shift_txt)[1]
    month = /^month\s*=\s*(\w{3}$)/.match(shift_txt)[1]
    @month = Month.new year, month
  end

  def set_unit config_txt
    @ws = Hash.new
    config_txt.scan(/^ws(\d+)\s*=\s*(\d{2}:\d{2})\s*-\s*(\d{2}:\d{2})$/).each do |item|
      @ws[item[0].to_i] = {during: [item[1], item[2]]}
    end
    @ws.each do |key, val|
      @ws[key][:minute] =  time_diff(val[:during])
    end
    config_txt.scan(/^ppws(\d+)\s*=\s*(\d+)$/).each do |item|
      @ws[item[0].to_i][:by_psn] = item[1].to_i
    end
    config_txt.scan(/^pow(\d+)\s*=\s*(\d+)$/).each do |item|
      @ws[item[0].to_i][:limit] = item[1].to_i
    end
  end

  def set_table shift_txt
    @table = Hash.new
    
    shift_txt.each_line do |line|
      name = ""
      pow = 0
      ws_condit= Hash.new 
      d_condit = Hash.new

      line.split(/\s*,\s*/).each do |confs|
        item = confs.split(/\s*=\s*/)

        case item[0]
        when "name"
          name = item[1].chomp
        when "pow"
          pow = item[1].chomp
        when /ws_per\d+/
          ws_condit[/ws_per(\d+)/.match(item[0])[1].to_i] = item[1].chomp.to_i
        when /d\d+/
          d_condit[/d(\d+)/.match(item[0])[1].to_i] = item[1].chomp.to_i
        end
	
        unless name == ""
          @table[name] = {condition: Condition.new(pow, ws_condit, d_condit),
                          shiftline: ShiftLine.new(@month.days_num, @ws.count)}
        end
      end
    end
  end

  def set_wish_to_table
    @table.each do |person, info|
      info[:condition].date.each do |date, wish|
        info[:shiftline].line[date-1].shift = wish
      end
    end
  end

  def changed
    @table.each do |person, info|
      off_count = 0
      on_count = 0
      minute_accum = 0
      ws_count = [0, 0, 0]

      info[:shiftline].line.each do |unit|
        case unit.shift
        when -1
        when 0
          off_count += 1 
        when 1..3
          on_count += 1
          minute_accum += @ws[unit.shift][:minute]
          ws_count[unit.shift-1] += 1
        end
      end
      
      info[:shiftline].sum[:off] = off_count 
      info[:shiftline].sum[:on] = on_count
      info[:shiftline].sum[:minute] = minute_accum
      ws_count.each_with_index {|ws, i| info[:shiftline].sum[:ws][i] = ws}
    end
  end

  def view
    print "|::Date\t: |"
    @month.days_num.times do |days|
      days += 1
      print "%2s|" % [days]
    end
    @ws.count.times do |ws_num|
      ws_num += 1
      print "%3s|" % ["ws#{ws_num}"]
    end
    puts "%3s|%3s|%6s|" % ["on", "off", "hours"]

    @table.each do |name, schedule|
      print "|#{name}\t: |"
      schedule[:shiftline].line.each do |unit|
        print "%2s|" % [unit.shift]
      end
      schedule[:shiftline].sum[:ws].each do |ws|
        print "%3s|" % [ws]
      end
      puts "%3s|%3s|%6s|" %
              [schedule[:shiftline].sum[:on], 
               schedule[:shiftline].sum[:off], 
               "#{schedule[:shiftline].sum[:minute]/60}:#{schedule[:shiftline].sum[:minute]%60}"]
    end
  end

  def time_diff time_ran
    to_minute = Array.new
    2.times do |i|
      /(\d{2}):(\d{2})/ =~ time_ran[i]
      to_minute[i] =  ($1.to_i)*60 + ($2.to_i)
    end
    to_minute[1] - to_minute[0]
  end
end
