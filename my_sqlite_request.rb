require 'csv'
require './methods.rb'

class MySqliteRequest

  def initialize
    @type_of_request  = :none
    @select_columns   = []
    @where_params     = nil
    @table            = nil
    @insert_attributes= []
    @table_name       = nil
    @order            = [] 
    @join             = {}
  end

  def from(table_name)
    @table_name = table_name
    self
  end

  def select(columns)
    if(columns.is_a?(Array))
      @select_columns += columns.collect {|elem| elem.to_s}
    elsif (columns.to_s == '*')
      @select_columns = nil;
    else
      @select_columns << columns.to_s
    end
    self._setTypeOfRequest(:select)
    self
  end

  def where(column_name, criteria)
    if(@where_params == nil)
      @where_params     = []
    end
    @where_params << [column_name, criteria]
    self
  end

  def join(column_on_db_a, filename_db_b, column_on_db_b)
    self._setTypeOfRequest(:join)
    @join = {column_a: column_on_db_a, column_b: column_on_db_b}
    @join_table = filename_db_b
    self
  end

  def order(order, column_name)
    self._setTypeOfRequest(:order)
    p @order << [order, column_name]
    self
  end

  def insert(table_name)
    self._setTypeOfRequest(:insert)
    @table_name = table_name
    self
  end

  def values(data)
    if(@type_of_request == :insert)
      @insert_attributes = data
    else
      raise 'Wrong type of request to call values()'
    end
    self
  end

  def set(data)
    self
  end


  def delete
    self._setTypeOfRequest(:delete)
    self
  end

  def print_select_type
    puts "Where Attributes #{@where_params}"
  end
  
  def print_insert_type
    puts "insert Attributes#{@insert_attributes}"
  end

  def print
    if(@type_of_request == :select)
      print_select_type
    elsif (@type_of_request == :insert)
      print_insert_type
    end
  end

  def run
    print
    if @table_name == nil
      @table_name = @filename
    end

    if check_file_exist(@table_name) <= 0
        puts 'File provided is empty.'
        puts "You can download one here https://storage.googleapis.com/qwasar-public/nba_player_data.csv"
        return 0
    end

    if(@type_of_request == :select)
      _run_select
    elsif(@type_of_request == :insert)
      _run_insert
    elsif(@type_of_request == :delete)
      _run_delete
    elsif(@type_of_request == :order)
      _run_order
    elsif(@type_of_request == :join)
      _run_join
    end
  end

  def _setTypeOfRequest(new_type)
    if(@type_of_request == :none or @type_of_request == new_type)
      @type_of_request = new_type
    else
      raise "Invalid: type of request already to #{@type_of_request} (new type => #{new_type})"
    end
  end
  
  def _run_select
    show_select()
  end

  def _run_insert
    insert_new()
  end

  def _run_delete
    delete_table()
    update()
  end
  
  def _run_order
    order_table()
    update()
  end

  def _run_join
    join_tables()
    update()
  end
end

def _main()
    request = MySqliteRequest.new

    ## UNCOMMENT ONLY ONE BLOCK AT A TIME (A BLOCK ENDS WHITH ## ==================================)


    # SELECT with no where
    # request = request.from('nba_player_data.csv')
    # request = request.select('name') # BE CAREFUL this one will print 4300+ lines
    # ==================================

    ## SELECT With one where
    # request = request.from('nba_player_data.csv')
    # request = request.select('name')
    # request = request.where('name', 'Don Adams')
    ## ==================================

    ## SELECT With multiple where
    # request = request.from('nba_player_data.csv')
    # request = request.select('name')
    # request = request.where('name', 'Don Adams')
    # request = request.where('weight', '210')
    ## ==================================


    ## INSERT a new line of csv
    # request = request.insert('nba_player_data.csv')
    # request = request.values({'name' => 'Alaa Abdelnaby', 'year_start' => '1991', 'year_end' => '1995', 'position' => 'F-C', 'height' => '6-10', 'weight' => '240', 'birth_date' => "June 24, 1968", 'college' => 'Duke University'})
    ## ==================================

    ## UPDATE a player
    # request = request.insert('nba_player_data.csv')
    # request = request.values('name' => 'Alaa Renamed')
    # request = request.where('name', 'Alaa Abdelnaby')
    ## ==================================
    
    ## DELETE one player who has WHERE
    # request = request.delete
    # request = request.from('nba_player_data.csv')
    # request = request.where('weight', '210')
    ## ==================================

    ## UNCOMMENT ALL THE NEXT PART IF YOU USE THE REQUEST SIDE AND COMMENT AGAIN AFTER
    ## VERY VERY IMPORTANT TO COMMENT IT AGAIN AFTER YOU FINISH USING REQUEST SIDE **OR** Client side wont work
    # request.run
end

_main()
