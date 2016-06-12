class Checker
  attr_reader :plan, :candid
  attr_reader :rule, :shift

  def initialize 
    set_rules IO.read './rules.txt'
    @plan = Hash.new
    @candid = Hash.new
  end

  def set_rules rules_txt
    @rule = Hash.new
    rules_txt.scan(/^(\w+)\s*=\s*(\d+)$/).each do |item|
      @rule[item[0]] = item[1].to_i
    end
    @rule["nap"] = Array.new
    rules_txt.scan(/^nap\s*=\s*([\d,]+)$/).each do |item|
      @rule["nap"] << item[0].split(/\s*,\s*/).map(&:to_i)
    end
  end

  def set_shift shift
    @shift = shift
  end

  def sum_check
    on_avg = @shift.table.inject(0) {|sum, person| sum += person[1][:shiftline].sum[:on]}
    off_avg = @shift.table.inject(0) {|sum, person| sum += person[1][:shiftline].sum[:off]}
    minute_avg = @shift.table.inject(0) {|sum, person| sum += person[1][:shiftline].sum[:minute]}
    [on_avg,off_avg,minute_avg]
  end

  def total_avg_check
    sum = sum_check
    mem_count = @shift.table.count.to_f
    flag = true

    @shift.table.each do |person, val|
      flag = false unless (val[:shiftline].sum[:on] - (sum[0]/mem_count)).abs <= @rule["on_dif"]
      flag = false unless (val[:shiftline].sum[:off] - (sum[1]/mem_count)).abs <= @rule["off_dif"]
      flag = false unless (val[:shiftline].sum[:minute] - (sum[2]/mem_count)).abs <= @rule["minute_dif"]
    end
    flag
  end

  def each_avg_check line
    result = 0
    sum = sum_check
    mem_count = @shift.table.count.to_f

    result += -10*(line[:on] - (sum[0]/mem_count))
    result += 10*(line[:off] - (sum[1]/mem_count))
    result += -10*(line[:minute] - (sum[2]/mem_count))/60
    
    result.to_i
  end

  def not_allowed line, date, ws
    result = 0
    @rule["nap"].each do |nap|
      first = date-(nap.count+1)
      last = date+(nap.count-1)

      if first < 0
        target = Array.new(-first,-1) + line[0..last].map(&:shift)
      elsif last > line.count-1
        target = line[first..(line.count-1)].map(&:shift) + Array.new(last-(line.count-1),-1)
      else
        target = line[first..last].map(&:shift)
      end

      target[date] = ws
      nap.count.times do |i|
        result += -50 if target[i..i+(nap.count-1)].join =~ /[#{nap.join("][")}]/
      end

      target[date] = 0
      nap.count.times do |i|
        result += 50 if target[i..i+(nap.count-1)].join =~ /[#{nap.join("][")}]/
      end
    end
    result
  end

  def each_line_check date, ws
    @shift.table.each do |person,val|
      @candid[person] += not_allowed(val[:shiftline].line, date, ws)
      @candid[person] += -100 if (@plan["unit"].select {|ws,psns| psns.include?(person)}) != {}
      @candid[person] += 200 if val[:condition].date[date+1] == ws
      @candid[person] += each_avg_check(val[:shiftline].sum)
    end
  end

  def pick_from_candid ws
    candid_a = @candid.to_a
    candid_a.shuffle!
    candid_a.sort! {|a,b| b[1] <=> a[1]}
    @plan["unit"][ws] = candid_a[0..@shift.ws[ws][:by_psn]-1].map {|arry| arry[0]}
  end

  def plan_init
    @shift.ws.count.times do |ws|
      @plan["unit"][ws+1] = Array.new(@shift.ws[ws+1][:by_psn])
    end
  end

  def candid_init
    @shift.table.each do |person,val|
      @candid[person] = 0
    end
  end

  def planning_date date
    @plan["date"] = date
    @plan["unit"] = Hash.new
    
    plan_init
    @shift.ws.count.times do |ws|
      candid_init
      each_line_check date, ws+1
      pick_from_candid ws+1
    end
    @plan
  end
end

