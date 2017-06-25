require 'csv'

class SearchZip
  input_file = "./indexd_zip.csv"
    
  puts "検索文字を入力してください。"
  search_words = gets.chomp.gsub(/[[:blank:]]+/, "").split("").uniq
  puts "検索中です..."
  csv = CSV.read(input_file, headers: false)
  result_array = []
  ix = 0
  while ix < csv.length() do
    hit_flg = false
    # 県を検索
    search_words.each do |search_word|
      row_id = csv[ix][0]
      pref_num = csv[ix][2]
      post_cd  = csv[ix][4]
      pref_kanji = csv[ix][5]
      city_kanji = csv[ix][6]
      town_kanji = csv[ix][7].to_s
      
      if pref_kanji.include?(search_word)
        hit_flg = true
        min_idx = row_id.to_i - 1      
        max_idx = min_idx + pref_num.to_i - 1
        min_idx.upto(max_idx) do |i|
          same_pref = csv[i]
          result_array.push([same_pref[4],same_pref[5],same_pref[6],same_pref[7].to_s])
        end
        # 県でマッチした分indexを進める
        ix += (max_idx - min_idx) + 1
        
        if ix >= csv.length()
          break
        end
        
      # 市区町村および町域名を検索
      elsif (city_kanji + town_kanji).include?(search_word)
        hit_flg = true
        post_cd  = csv[ix][4]
        pref_kanji = csv[ix][5]
        city_kanji = csv[ix][6]
        town_kanji = csv[ix][7].to_s
        result_array.push([post_cd,pref_kanji,city_kanji,town_kanji])
        ix += 1
        
        if ix >= csv.length()
          break
        end
        
      end
    end
    unless hit_flg
      ix += 1
    end  
  end

  puts "#{result_array.length()}件ヒットしました。"
  puts "================================================"
  result_array.each do |row|
  puts %Q{"#{row[0]}","#{row[1]}","#{row[2]}","#{row[3]}"}
  end
  puts "================================================"
  puts "#{result_array.length()}件の結果が表示されました。"
end