require 'mysql2'
require 'yaml'
require 'pry'

module ORM
  module DatabaseMethods
    def self.included(_kclass)
      def database_delegate
        ORM::DatabaseMethods.delegate
      end

      def sql_parse(query = {})
        binding.pry
        query.map do |key, value|
          "#{key}='#{database_delegate.escape(value.to_s)}'"
        end.join(' and ')
      end

      def columns_sql
        database_delegate.query("describe #{self.name.downcase}s").to_a
      end

      def where_query(query = {})
        query_string = sql_parse query
        "SELECT * FROM #{name.downcase!}s WHERE #{query_string}"
      end

      def find_query(query = {})
        "#{where_query(query)}"
      end

      def find_all_query
        "SELECT * FROM #{name.downcase!}s"
      end

      def save_sql(tables, props)
        columns = props.keys.join(',')
        values = props.values.map {|value| "'#{database_delegate.escape(value.to_s)}'"}.join(',')
        binding.pry
        database_delegate.query("INSERT INTO #{tables} (#{columns}) VALUES (#{values})")
      end

      def update_sql(tables, props, id)
        props = sql_parse props
        binding.pry
        database_delegate.query("UPDATE #{tables} SET #{props} WHERE id=#{id}")
      end

      def execute_sql(query_string)
        database_delegate.query("#{query_string} ORDER BY created_at DESC", symbolize_keys: true).to_a
      end
    end

    module_function

    def config_hash
      config_hash = YAML.load_file(File.dirname(__FILE__) << '/../../config/database.yml')
    end

    def delegate
      @client ||= Mysql2::Client.new(ORM::DatabaseMethods.config_hash['development'])
    end
  end
end

