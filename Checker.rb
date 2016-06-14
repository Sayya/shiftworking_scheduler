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
    @rule["rcm"] = Array.new
    rules_txt.scan(/^rcm\s*=\s*([\d,]+)$/).each do |item|
      @rule["rcm"] << item[0].split(/\s*,\s*/).map(&:to_i)
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
    result += 1*(line[:minute] - (sum[2]/mem_count))/60
    
    result.to_i
  end

  def recommended line, date, ws
    result = 0
    @rule["rcm"].each do |ptrn|
      first = date-(ptrn.count-1)
      last = date+(ptrn.count-1)

      if first < 0
        target = Array.new(-first,-1) + line[0..last].map(&:shift)
      elsif last > line.count-1
        target = line[first..(line.count-1)].map(&:shift) + Array.new(last-(line.count-1),-1)
      else
        target = line[first..last].map(&:shift)
      end

      target[ptrn.count-1] = ws
      ptrn.count.times do |i|
        if target[i..i+(ptrn.count-1)].join =~ /[#{ptrn.join("][")}]/
          result += 2
          #puts "rcm:#{ptrn}\ttarget:#{target[i..i+(ptrnn.count-1)]}" #debuging
        end
      end

      target[ptrn.count-1] = 0
      ptrn.count.times do |i|
        if target[i..i+(ptrn.count-1)].join =~ /[#{ptrn.join("][")}]/
          result += -2 
          #puts "rcm:#{ptrn}\ttarget:#{target[i..i+(ptrn.count-1)]}\tZERO" #debuging
        end
      end
    end
    result
  end

  def not_allowed line, date, ws
    result = [0, 0]
    @rule["nap"].each do |nap|
      first = date-(nap.count-1)
      last = date+(nap.count-1)

      if first < 0
        target = Array.new(-first,-1) + line[0..last].map(&:shift)
      elsif last > line.count-1
        target = line[first..(line.count-1)].map(&:shift) + Array.new(last-(line.count-1),-1)
      else
        target = line[first..last].map(&:shift)
      end

      target[nap.count-1] = ws
      nap.count.times do |i|
        if target[i..i+(nap.count-1)].join =~ /[#{nap.join("][")}]/
          result[1] = -1
          #puts "nap:#{nap}\ttarget:#{target[i..i+(nap.count-1)]}" #debuging
        end
      end

      target[nap.count-1] = 0
      nap.count.times do |i|
        if target[i..i+(nap.count-1)].join =~ /[#{nap.join("][")}]/
          result[0] += 100 
          #puts "nap:#{nap}\ttarget:#{target[i..i+(nap.count-1)]}\tZERO" #debuging
        end
      end
    end
    result
  end

  def shift_wish wish, ws, flag
    result = flag
    unless wish == nil
      if wish == 0
        result = -1 if 0 == wish
      else
        if ws.to_s =~ /[#{wish}]/
          if Math.log10(wish).to_i+1 > ws
            result = 1 if rand(Math.log10(wish).to_i+1) == 0
          else
            result = 1
          end
        else
          result = -1
        end
      end
    end
    result
  end

  def each_line_check date, ws
    @shift.table.each do |person,val|
      @candid[person][0] += each_avg_check(val[:shiftline].sum)
      @candid[person][0] += recommended(val[:shiftline].line, date, ws)

      nap_result = not_allowed(val[:shiftline].line, date, ws)
      @candid[person][0] += nap_result[0]
      @candid[person][1] = nap_result[1]
      #puts "#{person}: nap=#{nap_result[1]}" if nap_result[1] == -1 #debuging
      
      @candid[person][1] = shift_wish(val[:condition].date[date+1], ws, @candid[person][1])
      @candid[person][1] = -1 if (@plan["unit"].select {|ws,psns| psns.include?(person)}) != {}
    end
  end

  def test_power candid, psn_num, limit
    pre_plan = candid[0..psn_num-1]
    case pre_plan.inject(0) {|sum, psn| sum + @shift.table[psn][:condition].pow.to_i}
    when 0...limit
      next_candid = candid-[candid[psn_num-1]]
      #puts "#{pre_plan}:less power...next!" #debuging
      if next_candid.count >= psn_num
        test_power next_candid, psn_num, limit
      else
        #puts "but it's over...too young team..." #debuging
        pre_plan
      end
    else
      #puts "#{pre_plan}:OK!" #debuging
      pre_plan
    end
  end

  def pick_from_candid ws
    candid_a = @candid.to_a.select {|psn| psn[1][1] != -1}
    candid_a.shuffle!
    candid_a.sort! {|a,b| b[1][0] <=> a[1][0]}
    candid_a.sort! {|a,b| b[1][1] <=> a[1][1]}

    #p candid_a #debuging
    @plan["unit"][ws] = test_power (candid_a.map {|arry| arry[0]}),
                                    @shift.ws[ws][:by_psn],
                                    @shift.ws[ws][:limit]
  end

  def plan_init
    @shift.ws.count.times do |ws|
      @plan["unit"][ws+1] = Array.new(@shift.ws[ws+1][:by_psn])
    end
  end

  def candid_init
    @shift.table.each do |person,val|
      @candid[person] = [0, 0] 
    end
  end

  def planning_date date
    #puts "\n#{date+1},#{@shift.month.mon_name}" #debuging
    @plan["date"] = date
    @plan["unit"] = Hash.new
    
    plan_init
    @shift.ws.count.times do |ws|
      #puts "Shift-#{ws+1}" #debuging
      candid_init
      each_line_check date, ws+1
      pick_from_candid ws+1
    end
    @plan
  end
end

