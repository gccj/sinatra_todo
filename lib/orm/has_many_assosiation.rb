module ORM
  class HasManyAssociation

    def initialize(parent, name)
      @parent = parent
      @target_class = Object.const_get name
      @sql_query = []
    end

    def all
      parent_info = sql_restriction
      @target_class.class_eval { all(conditions: parent_info) }
    end

    def where(**query)
      query.merge! sql_restriction
      @target_class.class_eval { where(query) }
    end

    def find(**query)
      query.merge! sql_restriction
      @target_class.class_eval { find(query) }
    end

    def find_by(**query)
      query.merge! sql_restriction
      @target_class.class_eval { find_by(query) }
    end

    def first
      parent_info = sql_restriction
      @target_class.class_eval { first(conditions: parent_info) }
    end

    def last
      parent_info = sql_restriction
      @target_class.class_eval { last(conditions: parent_info) }
    end

    def build(props = {})
      attributes = sql_restriction.merge props
      @target_class.class_eval { new(attributes) }
    end

    def sql_restriction
      { :"#{@parent.class.name.downcase}_id" => @parent.id }
    end
  end
end
