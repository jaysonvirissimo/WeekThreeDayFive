require_relative '03_associatable'

# Phase IV
module Associatable
  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      through_table = through_options.table_name
      through_primary_key = through_options.primary_key
      through_foreign_key = through_options.foreign_key
      source_table = source_options.table_name
      source_private_key = source_options.primary_key
      source_foreign_key = source_options.foreign_key
      sql_query = <<-SQL
      SELECT
      #{source_table}.*
      FROM
      #{through_table}
      JOIN
      #{source_table}
      ON
      #{through_table}.#{source_foreign_key} = #{source_table}.#{source_private_key}
      WHERE
      #{through_table}.#{through_primary_key} = ?
      SQL

      value = send(through_foreign_key)
      results = DBConnection.execute(sql_query, value)

      source_options.model_class.parse_all(results).first
    end
  end
end
