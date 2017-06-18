require 'csv'

class CsvAddIndex
  input_file = "./test.csv"
  tmp_file = "./tmp.csv"
  result_file = "./indexd_zip.csv"
  
  # 引数:文字列オーバーで2分割された住所レコードの配列
  # 戻り値:マージ後の住所レコード
  def self.merge_split_data(merge_list)
    if (merge_list[0][0].to_i < merge_list[1][0].to_i)
      merged_row = [
                    merge_list[0][0],
                    merge_list[0][1],
                    merge_list[0][2],
                    merge_list[0][3],
                    merge_list[0][4],
                    merge_list[0][5],
                    merge_list[0][6] + merge_list[1][6] 
                   ]
    else
      merged_row = [
                    merge_list[1][0],
                    merge_list[1][1],
                    merge_list[1][2],
                    merge_list[1][3],
                    merge_list[1][4],
                    merge_list[1][5],
                    merge_list[1][6] + merge_list[0][6] 
                   ]
    end
    return merged_row
  end
  
  # 引数:csv出力したい配列 出力したいファイル名
  # 戻り値:なし
  def self.out_result_csv(result_array,out_file)
    CSV.open(out_file,"w") do |csv|
      result_array.each do |row|
        puts row[0]
        csv << row
      end
    end
  end

  # input file format
  # 0:全国地方公共団体コード
  # 1:旧郵便番号
  # 2:郵便番号
  # 3:都道府県 kana
  # 4:市区町村 kana
  # 5:町域名 kana
  # 6:都道府県 kanji
  # 7:市区町村 kanji
  # 8:町域名 kanji
  puts "============Start CsvAddIndex============"
  puts "reading csv....."
  csv_data = CSV.read(input_file, headers: false)
  headers = [
             "row_id",
             "prefecture_cd",
             "town_cd",
             "new_post_cd",
             "prefecture_kanji",
             "city_kanji",
             "town_kanji",
             "merge_key"
            ]
  
  CSV.open(tmp_file,"w") do |csv|
    csv << headers
    CSV.foreach(input_file) do |data|
      row_id = $.
      prefecture_cd = data[0][0,2]
      town_cd = data[0][2,3]
      new_post_cd = data[2]
      prefecuture_kana = data[3]
      city_kana = data[4]
      town_kana = data[5]
      prefecture_kanji = data[6]
      city_kanji = data[7]
      town_kanji = data[8]
      merge_key = new_post_cd + prefecuture_kana + city_kana + town_kana
      
      csv << [
              row_id,
              prefecture_cd,
              town_cd,
              new_post_cd,
              prefecture_kanji,
              city_kanji,
              town_kanji,
              merge_key
             ]
    end
  end

  # 結合対象レコードのキー取得 郵便番号と町域名カナで重複するもの
  table = CSV.table(tmp_file)
  target_list = table[:merge_key].group_by{|i| i}.reject{|key,value| value.one?}.keys
    
  #分割レコードの抽出
  #分割されていないレコードを配列へ格納
  puts "creat array of merged record"
  unmerged_list  = []
  result_array = []
  table.each do |data|
    merge_flg = false;
    # 分割されているレコード
    target_list.each do |str|
      if (data[:merge_key] == str)
        merge_flg = true
        unmerged_list.push(data)
      end
    end
    
    # 分割されていないレコード
    unless merge_flg
      # 結合行を特定するために保持していたmerge_keyカラムを削除
      data.delete(:merge_key)
      result_array.push(data)
    end
  end
  
  merged_list =[]
  target_list.each do |str|
    split_list = []
    #merge対象を配列に格納
    unmerged_list.each do |row|
      if (row[7] == str)
        split_list.push(row)
      end 
    end
     
    # 町域名をmergeする
    merged_row = merge_split_data(split_list)
    merged_list.push(merged_row) 
  end
  
  result_array.concat(merged_list)
  puts "create indexd_zip.csv"
  out_result_csv(result_array,result_file)
  
puts "============End CsvAddIndex============"
end
