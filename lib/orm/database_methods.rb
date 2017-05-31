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

      def where_clause(conditions = {})
        query_string = sql_parse conditions
        "WHERE #{query_string}"
      end

      def order_clause(by: 'created_at', order: 'DESC')
        "ORDER BY #{by} #{order}"
      end

      def limit_clause(num = 1)
        "LIMIT #{num.to_i}"
      end

      def from_clause(table: table_name)
        "FROM #{table}"
      end

      def select_clause(columns: '*')
        "SELECT #{columns}"
      end

      def where_query(query = {})
        default_option = { order: {}, limit: 0 }
        query_hash = default_option.merge(query)
        order = query_hash.delete(:order)
        limit = query_hash.delete(:limit)
        query_string = [select_clause, from_clause].join(' ')
        query_string = [query_string, where_clause(query_hash)].join(' ') if query_hash.any?
        query_string = [query_string, order_clause { order }].join(' ')
        query_string = [query_string, limit_clause(limit)].join(' ') if limit > 0
        query_string
      end

      def find_query(query = {})
        where_query(query)
      end

      def find_all_query(conditions: {})
        where_query conditions
      end

      def first_query(conditions: {})
        where_query(conditions.merge(order: { by: 'id', order: 'ASC' }, limit: 1))
      end

      def last_query(conditions: {})
        where_query(conditions.merge(order: { by: 'id' }, limit: 1))
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
        successfully_changed?
      end

      def update_sql(props, id)
        props = sql_parse props
        database_delegate.query("UPDATE #{table_name} SET #{props} WHERE id=#{id}")
        successfully_changed?
      end

      def delete_sql(id)
        database_delegate.query("DELETE FROM #{table_name} WHERE id=#{id}")
        successfully_changed?
      end

      def execute_sql(query_string)
        database_delegate.query(query_string.to_s, symbolize_keys: true).to_a
      end

      def successfully_changed?
        !database_delegate.affected_rows.zero?
      end
    end

    module_function

    def config_hash
      config_hash = YAML.load_file(File.dirname(__FILE__) << '/../../config/database.yml')
    end

    def delegate
      @client ||= Mysql2::Client.new(config_hash['development'])
    end
  end
end
