require "readline"
require "./my_sqlite_request.rb"

class MySqliteQueryCli

  def parse(buff)
    @buffer_values = []
    if buff.include? 'VALUES'
        @buffer_values = inserted_value_array(buff)
    else
        @buffer_values = buff.split(" ")
    end
    if @buffer_values.include? ("=")
        @buffer_values.delete_at(@buffer_values.index("="))
    end
    p @buffer_values.size
  end

  def select_opt

    @request = @request.from(@filename)
    @count_input = 3
   

    index = @buffer_values.index('SELECT')+1
    if @buffer_values[index] == nil 
      return -1
    end

    if valid_value(@buffer_values[index]) != true and @buffer_values[index] != "*"
      return -1
    end
    @count_input += 1 

    @request = @request.select(@buffer_values[index])

    if (check_index(@buffer_values, 'WHERE') > -1)
      value = select_where(@buffer_values[index], check_index(@buffer_values, 'WHERE'))
      if value == nil
        return -1
      end
      @count_input += 2
      index = @buffer_values.index('WHERE')+1
      @request = @request.where(@buffer_values[index],value)
    end
    
    if @count_input != @buffer_values.size
      return -1
    end

    return 1
  end

  def insert_opt
 
    @count_input = 2
    index = @buffer_values.index('INSERT')+1
    if @buffer_values[index] == nil and @buffer_values[index] != 'INTO'
      return -1
    end
    @count_input += 1 

    @reqiest = @request.insert(@filename)
    p @buffer_values
    if @buffer_values.include? 'VALUES'
        
      index = @buffer_values.index('VALUES')+1
      if @buffer_values[index] != nil
        p values = inserted_values(index)
        if (values == nil)
          puts "Please add all the values correctly."
          return -1
        end
        @count_input += 2
        @request = @request.values(values)
      else
        return -1
      end
    else
      return -1
    end
    puts @count_input
    if @count_input != @buffer_values.size
      return -1
    end

    return 1
  end

  def update_opt
    
    index = @buffer_values.index('UPDATE')+2
    @count_input = 2

    @request = @request.insert(@filename)
    
    if(@buffer_values[index] == nil and @buffer_values[index] != 'SET')
      return -1
    end
    @count_input += 1

    index += 1
    if valid_value(@buffer_values[index]) != true
      return -1
    end
    @count_input += 1
    
    hash_name = @buffer_values[index]
    value = check_value(index+1)
  
    values = {}
    values[hash_name] = value.to_s
    @request = @request.values(values)
    
    if check_index(@buffer_values, 'WHERE') == -1
        return -1
    end
    
    index = @buffer_values.index('WHERE')+1
    if(@buffer_values == nil)
      return -1
    end
    where_hash = @buffer_values[index]
    @count_input += 1

    where_value = select_where(@buffer_values[index], check_index(@buffer_values, 'WHERE'))
    if where_value == nil
      return -1
    end
    @count_input += 1

    if @count_input != @buffer_values.size
      return -1
    end
    @request = @request.where(where_hash, where_value)

    return 1

  end
  
  def delete_opt

    @request = @request.delete
    @request = @request.from(@filename)
    @count_input = 3

    index = @buffer_values.index('WHERE')+1
    if(@buffer_values == nil)
      return -1
    end
    where_hash = @buffer_values[index]
    @count_input += 1

    where_value = select_where(@buffer_values[index], check_index(@buffer_values, 'WHERE'))
    if where_value == nil
      return -1
    end
    @count_input += 1

    if @count_input != @buffer_values.size
      return -1
    end
    @request = @request.where(where_hash, where_value)

    return 1

  end

  def action
    # checks if first command has quit
    if @buffer_values.include? 'QUIT'
      return 0
    end

    @request = MySqliteRequest.new

    # Gets the file name 
    if(@buffer_values.include? 'INSERT')
      @filename = get_filename('INTO');
    elsif @buffer_values.include? 'UPDATE'
      @filename = get_filename('UPDATE')
    else
      @filename = get_filename('FROM')
    end
    if(@filename == nil)
      puts 'Wrong .csv file.'
      return 0
    end

    # Start taking action of one of the exists 
    if @buffer_values.include? 'SELECT'
      if select_opt() == -1
        return -1 
      end

    elsif @buffer_values.include? 'INSERT'
      if insert_opt() == -1
        return-1
      end

    elsif @buffer_values.include? 'UPDATE'
      if update_opt() == -1
        return -1
      end

    elsif @buffer_values.include? 'DELETE'
      if delete_opt() == -1
        return -1
      end

    end

    @request.run
    return 1
  end

  def run!
    continue = 1
    while continue != 0

      buff = Readline.readline("> ", true)
      parse(buff)

      continue = action

      if continue == -1
        puts "Error: wrong input, please try again."
      end

    end
  end

end

msqcli = MySqliteQueryCli.new
msqcli.run!
