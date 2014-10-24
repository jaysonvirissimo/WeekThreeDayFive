require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns_query
    "SELECT * FROM #{table_name} LIMIT 1"
  end

  def self.columns
    column_names = DBConnection.execute2(self.columns_query).first.collect(&:intern)
  end

  # Call finalize! at the end of any subclasses of SQLObject.
  def self.finalize!
    columns.each do |column_name|
      define_method(column_name) do
        self.attributes[column_name]
      end
      define_method("#{column_name}=") do |value|
        self.attributes[column_name] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.find_all_query
    "SELECT #{table_name}.* FROM #{table_name}"
  end

  def self.all
    self.parse_all(DBConnection.execute(self.find_all_query))
  end

  def self.parse_all(results)
    results.map do |hash|
      self.to_s.constantize.new(hash)
    end
  end

  def self.find_by_id_query
    "SELECT * FROM #{table_name} WHERE #{table_name}.id = ?"
  end

  def self.find(id)
    self.parse_all(DBConnection.execute(self.find_by_id_query, id)).first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.columns.include?(attr_name.intern)
        raise "unknown attribute '#{attr_name}'"
      end
      self.send("#{attr_name}=".intern, value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
