# frozen_string_literal: true

module ArelQuery
  extend ActiveSupport::Concern

  module Cast
    def self.included(mod)
      mod.class_eval do
        alias_method :create_cast, :cast if method_defined?(:cast)

        def cast(type)
          ::Arel::Nodes::NamedFunction.new "CAST", [self.as(type)]
        end
      end
    end
  end

  class WithHelper
    attr_reader :name

    def initialize(name, relation)
      raise ArgumentError, 'Name must be a Symbol or String' unless name.is_a?(Symbol) || name.is_a?(String)
      raise ArgumentError, 'Relation must be an Arel node or select manager' unless relation.is_a?(Arel::Nodes::Node) || relation.is_a?(Arel::SelectManager)

      @name     = name
      @relation = relation
    end

    def [](column)
      table[column]
    end

    def table
      @table ||= Arel::Table.new(@name)
    end

    def to_cte
      Arel::Nodes::Cte.new(@name, @relation)
    end
  end

  class ArelHelper
    attr_reader :model

    delegate :star, :sql, to: Arel
    delegate :project, :where, :from, :join, :outer_join, :group, :order, :alias, to: :@table
    delegate :with, to: :from

    def initialize(model)
      @model = model
      @table = model.arel_table if model.respond_to?(:arel_table)
    end

    def table(name = nil)
      if name
        Arel::Table.new(name)
      elsif @table
        @table
      else
        raise ArgumentError, 'No table available. Provide a table name.'
      end
    end

    alias t table

    def literal(value)
      Arel::Nodes::SqlLiteral.new(value.to_s)
    end

    alias l   literal
    alias lit literal

    def string(value)
      literal "'#{value}'"
    end

    alias s   string
    alias str string

    # @return [Arel::SelectManager]
    def select(...)
      Arel::SelectManager.new(...)
    end

    def as(what, alias_name)
      raise ArgumentError, 'Alias name must be a Symbol or String' unless alias_name.is_a?(Symbol) || alias_name.is_a?(String)

      Arel::Nodes::As.new(what, literal(alias_name))
    end

    def for_with(name, relation)
      WithHelper.new(name, relation)
    end

    def results(query)
      connection.select_all(query)
    end

    def rows(query)
      results(query).to_a
    end

    def connection
      ActiveRecord::Base.connection
    end

    def respond_to_missing?(_method_name, _include_private = false)
      true
    end

    FUNCTION_METHOD_PATTERN = /\A[a-z]+(_[a-z]+)*\z/

    def method_missing(method_name, *args, &block)
      node_class = "Arel::Nodes::#{method_name.to_s.camelize}".safe_constantize

      if node_class
        self.class.define_method method_name do |*method_args|
          node_class.new(*method_args)
        end
      elsif @table&.respond_to?(method_name)
        return @table.send(method_name, *args)
      elsif method_name.to_s =~ FUNCTION_METHOD_PATTERN
        self.class.define_method method_name do |*method_args|
          Arel::Nodes::NamedFunction.new(method_name.to_s, method_args)
        end
      else
        return super
      end

      send(method_name, *args)
    end

    def column(name)
      @table[name]
    end

    alias col column
    alias c   column

    def [](it)
      case it
      when Symbol
        @table[it]
      when String
        string(it)
      else
        literal(it)
      end
    end
  end

  class_methods do
    def aq(*args)
      @arel_helper ||= ArelHelper.new(self)
      args.empty? ? @arel_helper : @arel_helper.sql(*args)
    end
  end

  included do
    def aq(...)
      self.class.aq(...)
    end
  end
end

ActiveSupport.on_load :active_record do
  class ::Arel::SelectManager
    def table
      @ast.cores[0].source.left
    end

    def join_to(other, from: :id, to: :id, on: nil, type: :inner)
      on ||= table[from].eq(other[to])
      join_node_class = case type
                        when :inner        then Arel::Nodes::InnerJoin
                        when :left, :outer then Arel::Nodes::OuterJoin
                        when :right        then Arel::Nodes::RightOuterJoin
                        when :full         then Arel::Nodes::FullOuterJoin
                        else raise ArgumentError, "Unknown join type: #{type.inspect}"
                        end

      other = other.table if other.respond_to?(:table)
      join(other, join_node_class).on(on)
    end
  end

  ::Arel::Nodes::Node.include(ArelQuery::Cast)
  ::Arel::Attributes::Attribute.include(ArelQuery::Cast)
end
