KEYWORDS = ["SELECT", "INSERT", "UPDATE", "DELETE", "FROM", "WHERE", "INTO", "SET"]

def check_index(array, key)
  if array.include?(key)
    return array.index(key)+1
  end
  return -1
end

def get_filename(from)
  if check_index(@buffer_values, from) > -1 
    index = check_index(@buffer_values, from)
    if(@buffer_values[index] != nil and @buffer_values[index].include?('.csv'))
      return @buffer_values[index]
    end
  end
  return nil
end

def valid_value(value)
  list_values = CSV.open(@filename, &:readline)
  if(list_values.include?(value))
    return true
  else
    return false
  end
end


def check_value(index)
  str = @buffer_values[index].to_s.gsub("=", "").gsub(" ", "")
  @count_input += 1
  index+=1
  while(KEYWORDS.include?(@buffer_values[index]) != true and @buffer_values[index] != nil )
    str = str + " " 
    str = str + @buffer_values[index].to_s.gsub(" ", "")
    @count_input += 1
    index+=1
  end
  str = str.gsub("=", "").gsub("\"", "").chomp('\'').reverse.chomp('\'').reverse
  return str
end

def select_where(by, index)
  if valid_value(@buffer_values[index])
    value = check_value(index+1);
    return value
  end
  return nil
end

def inserted_values(str)
  str = str.gsub("(","").gsub(")", "")
  array = str.split(',')
  index = 0

  list_values = CSV.open(@filename, &:readline)

  values = {}

  list_values.each do |hash|
    if hash == 'birth_date'
      values[hash] = array[index].gsub("\"", "") + ',' + array[index+1].gsub("\"", "")
      index+=2
      next
    end
    values[hash] = array[index].to_s.gsub("\n", "").gsub("\"", "")
    index+=1
  end

  if index-1 != list_values.size
    return nil
  end

  return values
end

def delete_table
  @table = CSV.table(@table_name, headers: true)
  if(@where_params != nil)
    @table.delete_if do |row|
      row[:"#{@where_params[0][0]}"].to_s == @where_params[0][1].to_s
    end
  else
    @table.delete_if do |row|
      row
    end
  end
end

def update
  File.open(@table_name, 'w') do |f|
    f.write(@table.to_csv)
  end
end

def show_select
  result = []
  if(@where_params != nil)
    CSV.parse(File.read(@table_name), headers: true).each do |row|
      @where_params.each do |where_attribute|
        if row[where_attribute[0]] == where_attribute[1]
          if(@select_columns != nil) 
            result << row.to_hash.slice(*@select_columns)
          else
            result << row.to_hash
          end
        end
      end
    end
  else
    CSV.parse(File.read(@table_name), headers: true).each do |row|
      if(@select_columns != nil) 
        result << row.to_hash.slice(*@select_columns)
      else
        result << row.to_hash
      end
    end
  end
  puts result
end

def insert_new
  if(@where_params != nil)
    @table = CSV.table(@table_name, headers:true)
    @table.each do |row|
      if row[:"#{@where_params[0][0]}"].to_s == @where_params[0][1].to_s
        row[:"#{@where_params[0][0]}"] = @insert_attributes.values.join('"')
      end
    end
    update()
  else
    CSV.open(@table_name, 'ab', :row_sep => "", :col_sep => ",") do |csv| 
      csv << @insert_attributes.values
    end
  end
end

def order_table
  @table = CSV.table(@table_name)
  0.upto @table.length-1 do |i|
    i.upto @table.length-1 do |j|
      row_i = @table[i]
      row_j = @table[j]

      value_i = row_i[:"#{@order[0][1]}"]
      value_j = row_j[:"#{@order[0][1]}"]

      if @order[0][0] == :asc
        if value_i > value_j
          temp = @table[i]
          @table[i] = @table[j]
          @table[j] = temp
        end
      elsif @order[0][0] == :desc
        if value_i < value_j
          temp = @table[i]
          @table[i] = @table[j]
          @table[j] = temp
        end
      end
    end
  end
end

def join_tables

  @table = CSV.table(@table_name)
  @second_table = CSV.table(@join_table)
  @filename = @table_name

  @second_table.each do |row|
    @table.push(row)
  end

end
