# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildCaseCycle, type: :model do
  it { should belong_to(:child) }
  it { should belong_to(:case_cycle) }
  it { should belong_to(:subsidy_rule) }

  it { should validate_numericality_of(:part_days_allowed).is_greater_than(0) }
  it { should validate_numericality_of(:full_days_allowed).is_greater_than(0) }

  it 'factory should be valid (default; no args)' do
    expect(build(:child_case_cycle)).to be_valid
  end
end

# == Schema Information
#
# Table name: child_case_cycles
#
#  id                :uuid             not null, primary key
#  full_days_allowed :integer          not null
#  part_days_allowed :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  case_cycle_id     :uuid             not null
#  child_id          :uuid             not null
#  subsidy_rule_id   :uuid             not null
#
# Indexes
#
#  index_child_case_cycles_on_case_cycle_id    (case_cycle_id)
#  index_child_case_cycles_on_child_id         (child_id)
#  index_child_case_cycles_on_subsidy_rule_id  (subsidy_rule_id)
#
# Foreign Keys
#
#  fk_rails_...  (case_cycle_id => case_cycles.id)
#  fk_rails_...  (child_id => children.id)
#  fk_rails_...  (subsidy_rule_id => subsidy_rules.id)
#
