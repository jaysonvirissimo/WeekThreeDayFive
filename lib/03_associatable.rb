require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(:foreign_key, :class_name, :primary_key)

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name}_id".intern
    @class_name = options[:class_name] || name.to_s.camelcase
    @primary_key = options[:primary_key] || 'id'.intern
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    if options[:foreign_key]
      @foreign_key = options[:foreign_key]
    else
      @foreign_key = "#{self_class_name.underscore}_id".intern
    end
    @class_name = options[:class_name] || name.to_s.camelcase.singularize
    @primary_key = options[:primary_key] || 'id'.intern
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      foreign_key = send(options.foreign_key)
      options.model_class.where(options.primary_key => foreign_key).first
    end
  end

  def has_many(name, options = {})
    assoc_options[name] = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      primary_key = send(options.primary_key)
      options.model_class.where(options.foreign_key => primary_key)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
