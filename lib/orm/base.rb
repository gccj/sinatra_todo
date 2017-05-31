require 'database_methods'
require 'has_many_assosiation'
require 'pry'

module ORM
  class Base
    def self.inherited(klass)
      klass.extend ClassMethods
      klass.set_attributes
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
        @columns = {}
        columns_sql.each { |column| @columns[column['Field']] = column['Type'] }
        @columns
      end

      def as_boolean(attr)
        alias_method "#{attr}_getter".to_sym, attr.to_sym
        define_method(attr) do
          prop = send("#{attr}_getter")
          !prop.zero? if prop
        end
      end

      def set_attributes
        columns.each do |attr, type|
          attr_accessor attr
          define_singleton_method("find_by_#{attr}") do |query|
            find(attr.to_sym => query)
          end
          as_boolean attr if type == 'tinyint(1)'
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
            (allow_attributes.keys - self.class.columns.keys).each { |attr| allow_attributes.delete attr }
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

      def has_many(klasss)
        define_method(klasss) do
          target_class = klasss.to_s.capitalize
          target_class.slice!(-1)
          @associations ||= ORM::HasManyAssociation.new(self, target_class)
        end
      end

      def belongs_to(klass)
        define_method(klass) do
          Object.const_get(klass.capitalize).find_by(id: send("#{klass}_id"))
        end
      end

      def enum(**hash)
        enum_array = hash.first
        attr = enum_array.shift.to_s
        method_name = "#{attr}s"
        const_key = method_name.upcase
        attr_hash = Hash[enum_array.flatten!.map.with_index { |key, index| [key, index] }]
        const_set(const_key, attr_hash)
        define_singleton_method(method_name) do
          const_get const_key
        end
        alias_method :"#{attr}_getter", :"#{attr}"
        define_method(attr) do
          self.class.send(method_name).key(send("#{attr}_getter")).to_s
        end

        alias_method :"#{attr}_setter", :"#{attr}="
        define_method("#{attr}=") do |value|
          if !value || value.is_a?(Integer)
            send("#{attr}_setter", value)
          else
            send("#{attr}_setter", self.class.send(method_name)[value.to_sym])
          end
        end

        attr_hash.each do |key, value|
          define_method("#{key}?") do
            send("#{attr}_getter") == value
          end

          define_method("#{key}!") do
            update(attr.to_s => value)
          end
        end
      end

      def all(**conditions)
        instance_array = execute_sql(find_all_query(conditions))
        if instance_array.any?
          instance_array = instance_array.map do |instance|
            new instance
          end
        end
        instance_array
      end

      def where(**query)
        instance_array = execute_sql(where_query(query))
        if instance_array.any?
          instance_array = instance_array.map do |instance|
            new instance
          end
        end
        instance_array
      end

      def find(**query)
        instance_hash = execute_sql(find_query(query)).first
        new(instance_hash) if instance_hash
      end

      def find_by(**query)
        where(query.merge(limit: 1)).first
      end

      def first(**conditions)
        instance_hash = execute_sql(first_query(conditions)).first
        new(instance_hash) if instance_hash
      end

      def last(**conditions)
        instance_hash = execute_sql(last_query(conditions)).first
        new(instance_hash) if instance_hash
      end
    end
  end
end
