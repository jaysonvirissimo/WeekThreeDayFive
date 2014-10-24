require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns_query
    "SELECT * FROM #{table_name} LIMIT 1"
  end

  def self.columns
    DBConnection.execute2(self.columns_query).first.collect(&:intern)
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
    self.class.columns.map { |attribute_name| self.send(attribute_name) }
  end

  def insert_query(names, marks)
    "INSERT INTO #{self.class.table_name} (#{names}) VALUES (#{marks})"
  end

  def column_names
    self.class.columns.map(&:to_s).join(", ")
  end

  def question_marks
    array = []

    number_of_columns.times do
      array << "?"
    end

    array.join(", ")
  end

  def number_of_columns
    self.class.columns.length
  end

  def insert
    values = attribute_values
    DBConnection.execute(insert_query(column_names, question_marks), *values)
    self.id = DBConnection.last_insert_row_id
  end

  def set_line
    self.class.columns.map { |column_name| "#{column_name} = ?" }.join(", ")
  end

  def update_query
    "UPDATE #{self.class.table_name} SET #{set_line} WHERE id = ?"
  end

  def update
    DBConnection.execute(update_query, *attribute_values, self.id)
  end

  def save
    if id.nil? then insert else update end
  end
end
