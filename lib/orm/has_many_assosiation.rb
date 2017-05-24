module ORM
  class HasManyAssociation
    include ORM::DatabaseMethods

    def initialize(parent, name)
      @parent = parent
      @target_class = Object.const_get name
      @sql_query = []
    end

    def where(**query)
      query.merge! sql_restriction
      @target_class.class_eval { where(query) }
    end

    def find(**query)
      query.merge! sql_restriction
      @target_class.class_eval { find(query) }
    end

    def build
      parent_info = sql_restriction
      @target_class.class_eval { new(parent_info) }
    end

    def sql_restriction
      { :"#{@parent.class.name.downcase}_id" => @parent.id }
    end
  end
end
