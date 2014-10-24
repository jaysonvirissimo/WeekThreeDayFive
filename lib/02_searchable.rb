require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    parse_all(DBConnection.execute(where_query(params), *params.values))
  end

  def where_query(params)
    "SELECT * FROM #{self.table_name} WHERE #{where_line(params)}"
  end

  def where_line(params)
    params.keys.map { |column| "#{column} = ?" }.join(" AND ")
  end
end

class SQLObject
  extend Searchable
end
