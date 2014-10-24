require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    query = <<-SQL
    SELECT
      *
    FROM
      #{table_name}
    LIMIT
      1
    SQL
    column_names = DBConnection.execute2(query).first.collect(&:intern)
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

  def self.all
    query = <<-SQL
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    SQL
    array_of_hashes = DBConnection.execute(query)
    self.parse_all(array_of_hashes)
  end

  def self.parse_all(results)
    array_of_objects = []

    results.each do |hash|
      array_of_objects << self.to_s.constantize.new(hash)
    end

    array_of_objects
  end

  def self.find(id)
    query = <<-SQL
    SELECT
    *
    FROM
    #{table_name}
    WHERE
    #{table_name}.id = ?
    SQL
    hash = DBConnection.execute(query, id)
    self.parse_all(hash).first
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
