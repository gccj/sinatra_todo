require 'database_methods'
require 'has_many_assosiation'
require 'pry'

module ORM
  class Base
    def self.inherited(kclass)
      kclass.extend ClassMethods
      kclass.set_attributes
    end

    module ClassMethods
      include ORM::DatabaseMethods

      def create(**props)
        new(props).save
      end

      def build(**props)
        new(props)
      end

      def columns
        @columns = columns_sql.map { |column| column['Field'] }
      end

      def set_attributes
        columns.each do |attr|
          attr_accessor attr
          define_singleton_method("find_by_#{attr}") do |query|
            find(attr.to_sym => query)
          end
        end

        define_method(:initialize) do |hash = {}|
          hash.each do |key, value|
            send("#{key}=", value) if respond_to? "#{key}="
          end
        end

        define_method(:attributes) do
          attributes = {}
          instance_variables.each do |key|
            attributes[key.to_s.gsub(/@/, '')] = instance_variable_get key
          end
          attributes
        end

        define_method(:save) do
          if id
            update attributes
          else
            self.created_at ||= Time.now
            self.updated_at = self.created_at
            allow_attributes = attributes
            (allow_attributes.keys - self.class.columns).each { |attr| allow_attributes.delete attr }
            self.class.save_sql allow_attributes
          end
        end

        define_method(:update) do |params|
          params.delete('id')
          params.keep_if { |key, _value| respond_to? "#{key}=" }
          self.class.update_sql params, id
        end

        define_method(:destroy) do
          self.class.delete_sql id
        end
      end

      def has_many(kclasss)
        define_method(kclasss) do
          target_class = kclasss.to_s.capitalize
          target_class.slice!(-1)
          @associations ||= ORM::HasManyAssociation.new(self, target_class)
        end
      end

      def belongs_to(kclass)
        define_method(kclass) do
          Object.const_get(kclass.capitalize).find_by(id: id)
        end
      end

      def enum(*hash); end

      def all
        instance_array = execute_sql(find_all_query)
        unless instance_array.empty?
          instance_array.map do |instance|
            new instance
          end
        end
      end

      def where(**query)
        instance_array = execute_sql(where_query(query))
        if instance_array.empty?
          []
        else
          instance_array.map do |instance|
            new instance
          end
        end
      end

      def find(**query)
        instance_hash = execute_sql(find_query(query)).first
        new(instance_hash) if instance_hash
      end

      def find_by(**query)
        where(query).first
      end

      def first(**conditions)
        instance_hash = first_sql(conditions).first
        new(instance_hash) if instance_hash
      end

      def last(**conditions)
        instance_hash = last_sql(conditions).first
        new(instance_hash) if instance_hash
      end
    end
  end
end
