require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    data = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
      #{table_name}
    SQL
    data.first.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |col_name|

      define_method("#{col_name}=") do |setter|
        attributes[col_name] = setter
      end

      define_method(col_name) do
        attributes[col_name]
      end

    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    table_name = self.to_s.tableize
    @table_name ||= table_name
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
      #{table_name}
    SQL
    parse_all(data)
  end

  def self.parse_all(results)
    results.map {|attributes| self.new(attributes)}
  end

  def self.find(id)
    # ...
    data = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
      #{table_name}
      WHERE
        #{table_name}.id = ?
      LIMIT
        1
    SQL
    return nil if data.empty?
    new(data.first)
  end

  def initialize(params = {})
    params.each do |key, val|
      key = key.to_sym
      raise "unknown attribute '#{key}'" unless self.class.columns.include?(key)
      send("#{key}=", val)
    end
  end

  def attributes
    # ...
    @attributes ||= {}
  end

  def attribute_values
    # ...
    self.class.columns.map { |key| send(key)}
  end

  def insert
    # ...
    n = attribute_values.length

    question_marks = Array.new(n, "?").join(", ")

    col_names = self.class.columns.join(", ")

    table_name = self.class.table_name

    data = DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
      #{table_name} (#{col_names})
      VALUES
      ( #{question_marks} )
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    # ...
    table_name = self.class.table_name
    col_names = self.class.columns.map{ |column| "#{column} = ?" }.join(", ")
    where_id = "id = #{send(:id)}"
    data = DBConnection.execute(<<-SQL, *attribute_values)
      UPDATE
      #{table_name}
      SET
       #{col_names}
      WHERE
      #{where_id}
    SQL

  end

  def save
    # ...
    id = send(:id)
    if id.nil?
      insert
    else
      update
    end
  end
end
