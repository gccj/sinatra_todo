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
        query.map do |key, value|
          if value.to_s.casecmp('true').zero? || value.to_s.casecmp('false').zero?
            "#{key}=#{database_delegate.escape(value.to_s)}"
          else
            "#{key}='#{database_delegate.escape(value.to_s)}'"
          end
        end.join(' and ')
      end

      def table_name
        "#{name.downcase!}s"
      end

      def columns_sql
        database_delegate.query("describe #{table_name}").to_a
      end

      def where_query(query = {})
        query_string = sql_parse query
        "SELECT * FROM #{table_name} WHERE #{query_string}"
      end

      def find_query(query = {})
        where_query(query).to_s
      end

      def find_all_query(conditions: {})
        if conditions.empty?
          "SELECT * FROM #{table_name}"
        else
          conditions_string = sql_parse conditions
          "SELECT * FROM #{table_name} WHERE #{conditions_string}"
        end
      end

      def first_sql(limit: 1, conditions: {})
        if conditions.empty?
          database_delegate.query("SELECT * FROM #{table_name} LIMIT #{limit.to_i}").to_a
        else
          conditions_string = sql_parse conditions
          database_delegate.query("SELECT * FROM #{table_name} WHERE #{conditions_string} LIMIT #{limit.to_i}").to_a
        end
      end

      def last_sql(limit: 1, conditions: {})
        if conditions.empty?
          database_delegate.query("SELECT * FROM #{table_name} ORDER BY 'id' DESC LIMIT #{limit.to_i}").to_a
        else
          conditions_string = sql_parse conditions
          database_delegate.query("SELECT * FROM #{table_name} WHERE #{conditions_string} ORDER BY 'id' DESC LIMIT #{limit.to_i}").to_a
        end
      end

      def save_sql(props)
        columns = props.keys.join(',')
        values = props.values.map do |value|
          if value.to_s.casecmp('true').zero? || value.to_s.casecmp('false').zero?
            database_delegate.escape(value.to_s).to_s
          else
            "'#{database_delegate.escape(value.to_s)}'"
          end
        end.join(',')
        database_delegate.query("INSERT INTO #{table_name} (#{columns}) VALUES (#{values})")
        database_delegate.last_id
      end

      def update_sql(props, id)
        props = sql_parse props
        database_delegate.query("UPDATE #{table_name} SET #{props} WHERE id=#{id}")
        database_delegate.last_id
      end

      def delete_sql(id)
        database_delegate.query("DELETE FROM #{table_name} WHERE id=#{id}")
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
