require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)

  end

  def where_query
    "SELECT * FROM #{self.class.table_name} WHERE #{where_line}"
  end

  def where_line
    ""
  end
end

class SQLObject
  # Mixin Searchable here...
end
