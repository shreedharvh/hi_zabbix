# Public: Various methods to construct jira formatted string to post a table/list on the jira
# All methods are class methods and should be called on JiraCommentFormat class
class JiraCommentFormat
  # Public: This method returns a jira formatted string for a table output 
  #
  # input - table details(columns, rows, headers/title/footer if any) to be commented on the jira (Hash)
  #
  # Example -
  # JiraCommentFormat::table_format({'columns' => ['date', 'status'], 'rows' => [['2012-12-12', true],['2013-12-12', false]]})
  # => "||date||status\n|2012-12-12|(/)\n|2013-12-12|(x)"
  #
  # Returns a string if the input is valid
  # Raises error if columns and rows are not specified in the input
  def self.table_format(input)
    # input = { 'header' => '', 'footer' = > '', 'title' => '', 'columns' => [], 'rows' => [[],[]] }
    raise 'Please provide columns/rows values in the input' unless input.key?('columns') && input.key?('rows')
    formatted_string = ''
    ['header', 'title'].each do |content|
      formatted_string.concat("\n\n#{input[content]}\n\n") if input.key?(content)
    end
    input['columns'].each do |column|
      formatted_string.concat("||#{column}")
    end
    input['rows'].each do |row|
      formatted_string.concat("\n")
      row.each do |value|
        # checking if the value is boolean. If yes, printing the corresponding symbol or display as it is, otherwise.
        # For eg, if the value is true, it is represented as '(/)' in jira.
        # if the value is 'northamerica.cerner.net', it will be printed as it is.
        if !!value == value
          pattern = value ? '(/)' : '(x)'
          formatted_string.concat("|#{pattern}")
        else
          formatted_string.concat("|#{value}")
        end
      end
    end
    formatted_string.concat("\n\n#{input['footer']}\n\n") if input.key?('footer')
    return formatted_string
  end

  # Public: This method returns a jira formatted string for a list output 
  #
  # input - list details(list, type, headers/title/footer if any) to be commented on the jira (Hash)
  #
  # Example -
  # JiraCommentFormat::list_format({'type' => 'numbered', 'list' => [ 'A', 'B', 'C'] })
  # => "# A\n# B\n# C\n"
  # JiraCommentFormat::list_format({'title' => 'List comment', 'list' => [ 'A', 'B', ['B.1', 'B.2'], 'C'] })
  # => "List Comment\n\n* A\n* B\n** B.1\n** B.2\n* C\n\n"
  #
  # Returns a string if the input is valid
  # Raises error if list is not specified in the input
  def self.list_format(input)
    # input = { 'header' => '', 'footer' => '', 'title' => '', 'type' => '', 'list' => [] }
    raise 'Please provide list values in the input' unless input.key?('list')
    formatted_string = ''
    ['header', 'title'].each do |content|
      formatted_string.concat("\n\n#{input[content]}\n\n") if input.key?(content)
    end
    counter = 1
    symbol = (input['type'] == 'numbered') ? '#' : '*'

    def self.parse_list(arr,counter,symbol)
      str = ''
      arr.each do |item|
        if item.class == Array
          str.concat(parse_list(item,counter+1,symbol))
        else
          counter.times { str.concat(symbol.to_s) }
          str.concat(" #{item}\n")
        end
      end
      str
    end
    formatted_string.concat(parse_list(input['list'],counter,symbol))
    formatted_string.concat("\n\n#{input['footer']}\n\n") if input.key?('footer')
    return formatted_string
  end

  # Public: This method returns a jira formatted string for a miscellaneous output 
  #
  # input - miscellaneous input details(format, hash value in case of table/list or String value, ) (Array of Hashes)
  #
  # Example -
  # JiraCommentFormat::miscellaneous_format([{'format' => 'list',
  #                                           'value' => {'list' => [ 'A', 'B', ['B.1', 'B.2'], 'C'] }},
  #                                          {'format' => 'table',
  #                                           'value' => {'columns' => ['date'], 'rows' => [['2012-12-12'],['2013-12-12']]}}])
  # => "* A\n* B\n** B.1\n** B.2\n* C\n||date\n|2012-12-12\n|2013-12-12"
  #
  # Returns a string if the input is valid
  # Raises error if input format/value is invalid
  def self.miscellaneous_format(input)
    # input  = [ { 'format' => '', 'value' => {}/String } ]
    formatted_string = ''
    input.each do |element|
      raise 'Please provide format and value in the input' unless element.key?('format') && element.key?('value')
      case element['format']
      when 'string'
        formatted_string.concat("\n\n#{element['value']}\n\n")
      when 'table'
        formatted_string.concat("\n\n#{table_format(element['value'])}\n\n")
      when 'list'
        formatted_string.concat("\n\n#{list_format(element['value'])}\n\n")
      else
        raise "Invalid comment format : '#{element['format']}' specified"
      end
    end
    return formatted_string
  end

end