# frozen_string_literal: true

describe ArelQuery do
  # ArelQuery is already included in RrxApi::Record → ApplicationRecord → Widget
  subject(:model) { Widget }

  before do
    Widget.delete_all
  end

  describe '.aq' do
    it 'returns an ArelHelper instance when called with no args' do
      expect(model.aq).to be_a(ArelQuery::ArelHelper)
    end

    it 'returns a SQL literal when called with a string' do
      literal = model.aq('1=1')
      expect(literal).to be_a(Arel::Nodes::SqlLiteral)
    end

    it 'memoises the helper across calls' do
      expect(model.aq).to be(model.aq)
    end
  end

  describe 'ArelHelper#table' do
    subject(:aq) { model.aq }

    it 'returns the model table when called with no args' do
      expect(aq.table).to be_a(Arel::Table)
      expect(aq.table.name).to eq 'widgets'
    end

    it 'returns a named table when called with a name' do
      t = aq.table(:other_table)
      expect(t).to be_a(Arel::Table)
      expect(t.name).to eq 'other_table'
    end

    it 'aliases #t to #table' do
      expect(aq.t).to eq aq.table
    end
  end

  describe 'ArelHelper#literal and aliases' do
    subject(:aq) { model.aq }

    it '#literal returns a SqlLiteral' do
      expect(aq.literal('NOW()')).to be_a(Arel::Nodes::SqlLiteral)
    end

    it '#l is an alias for #literal' do
      expect(aq.l('x')).to eq aq.literal('x')
    end

    it '#lit is an alias for #literal' do
      expect(aq.lit('x')).to eq aq.literal('x')
    end
  end

  describe 'ArelHelper#string and aliases' do
    subject(:aq) { model.aq }

    it "wraps value in single quotes" do
      expect(aq.string('hello').to_s).to eq "'hello'"
    end

    it '#s is an alias for #string' do
      expect(aq.s('x')).to eq aq.string('x')
    end

    it '#str is an alias for #string' do
      expect(aq.str('x')).to eq aq.string('x')
    end
  end

  describe 'ArelHelper#column and aliases' do
    subject(:aq) { model.aq }

    it 'returns an Arel attribute' do
      expect(aq.column(:name)).to be_a(Arel::Attributes::Attribute)
    end

    it '#c is an alias for #column' do
      expect(aq.c(:name)).to eq aq.column(:name)
    end

    it '#col is an alias for #column' do
      expect(aq.col(:name)).to eq aq.column(:name)
    end
  end

  describe 'ArelHelper#[]' do
    subject(:aq) { model.aq }

    it 'looks up a column by symbol' do
      expect(aq[:name]).to be_a(Arel::Attributes::Attribute)
    end

    it 'wraps a string in single quotes' do
      expect(aq['hello'].to_s).to eq "'hello'"
    end

    it 'returns a literal for other values' do
      expect(aq[42]).to be_a(Arel::Nodes::SqlLiteral)
    end
  end

  describe 'ArelHelper#as' do
    subject(:aq) { model.aq }

    it 'creates an Arel::Nodes::As node' do
      node = aq.as(aq.c(:name), :widget_name)
      expect(node).to be_a(Arel::Nodes::As)
    end

    it 'raises for non-string/symbol alias names' do
      expect { aq.as(aq.c(:name), 42) }
        .to raise_error(ArgumentError, /Alias name/)
    end
  end

  describe 'ArelHelper method_missing (named functions)' do
    subject(:aq) { model.aq }

    it 'creates a NamedFunction for snake_case method names' do
      node = aq.upper(aq.c(:name))
      expect(node).to be_a(Arel::Nodes::NamedFunction)
      expect(node.name).to eq 'upper'
    end

    it 'caches the dynamic method after first call' do
      aq.json_extract(aq.c(:name))
      expect(aq.class.instance_methods).to include(:json_extract)
    end
  end

  describe 'Cast module on Arel nodes' do
    subject(:aq) { model.aq }

    it 'adds #cast to Arel::Attributes::Attribute' do
      node = aq.c(:weight).cast('TEXT')
      expect(node).to be_a(Arel::Nodes::NamedFunction)
      expect(node.name).to eq 'CAST'
    end

    it 'adds #cast to Arel::Nodes::Node' do
      # Use an attribute node; SqlLiteral is a String subclass, not an Arel::Nodes::Node.
      node = aq.c(:name).cast('INTEGER')
      expect(node).to be_a(Arel::Nodes::NamedFunction)
    end
  end

  describe 'WithHelper' do
    subject(:aq) { model.aq }

    it 'raises for non-string/symbol names' do
      expect { ArelQuery::WithHelper.new(42, model.all.arel) }
        .to raise_error(ArgumentError, /Name must be a Symbol or String/)
    end

    it 'raises for non-Arel relations' do
      expect { ArelQuery::WithHelper.new(:cte, 'not_arel') }
        .to raise_error(ArgumentError, /Relation must be an Arel node/)
    end

    it 'provides [] column access on the CTE table' do
      wh = aq.for_with(:cte_widgets, model.all.arel)
      expect(wh[:id]).to be_a(Arel::Attributes::Attribute)
    end

    it '#to_cte returns an Arel::Nodes::Cte' do
      wh = aq.for_with(:cte_widgets, model.all.arel)
      expect(wh.to_cte).to be_a(Arel::Nodes::Cte)
    end
  end

  describe 'Arel::SelectManager#join_to patch' do
    it 'returns a select manager with the join applied' do
      other = Arel::Table.new(:other)
      sm    = Widget.arel_table.from
      expect { sm.join_to(other) }.not_to raise_error
    end

    it 'raises for unknown join type' do
      other = Arel::Table.new(:other)
      sm    = Widget.arel_table.from
      expect { sm.join_to(other, type: :banana) }
        .to raise_error(ArgumentError, /Unknown join type/)
    end
  end

  describe 'instance #aq delegates to class' do
    it 'delegates to Widget.aq' do
      widget = Widget.new
      expect(widget.aq).to be(Widget.aq)
    end
  end
end
