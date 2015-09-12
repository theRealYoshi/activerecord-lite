require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)

    table_name = self.table_name

    where = params.keys.map { |param| "#{param} = ?"}.join(" AND ")
    data = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        #{table_name}.*
      FROM
      #{table_name}
      WHERE
        #{where}
    SQL
    parse_all(data)
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
