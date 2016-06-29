# shiftworking_scheduler

#####################################

# main_scheduler.rb のメインプロセス
------------------
c = Checker.new
t = ShiftTable.new

c.set_shift t

t.month.days_num.times do |num|
  t.apply c.planning_date(num)
end
------------------

# Checker に ShiftTable をセット
------------------
c.set_shift t
------------------

# その月の日数分処理する
------------------
t.month.days_num.times do
------------------

# x日の plan を作成
------------------
c.planning_date x
------------------

# plan を元に ShiftTable を変更
------------------
t.apply plan
------------------

#####################################

plan の中身

{"date"=>0, 
  "unit"=>{1=>["Tsumur", "Kodama", "Sakura"], 
           2=>["Saito", "Kitaga", "Kanaza"], 
           3=>["Ishida", "Daiguj", "Morish"]}}

#####################################

candid_a (Checker.rb) の中身

candid_a[0] = 名前
candid_a[1][0] = 優先順位点
candid_a[1][1] = 最優先フラグ
------------------
[
["Toda", [1008, 0]], 
["Nagaok", [12, 0]], 
["Hosoka", [8, 0]], 
["Suzuki", [5, 0]], 
["Tsumur", [-1, 0]], 
["Kitaga", [-49, 0]]
]
------------------
# 優先順位点
この点の高い順に勤務帯の勤務者が選ばれる

# 最優先フラグ
-1 = 候補から除外される
 0 = Normal
 1 = ソートされ、一番上に来、もっとも選ばれやすくなる

#####################################

Checker 条件の優先順位

※以下メソッドに書かれている
------------------
def each_line_check date, ws
------------------

0. 最優先フラグ -1 の排除
1. 一人が一日に2回以上選ばれないための処理 (最優先フラグ -1 を設定)
2. 希望休、希望勤務設定 (shift.txt)
3. 禁止パターン (not allowed pattern) (最優先フラグ -1 を設定)

#####################################




