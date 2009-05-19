# -*- coding: utf-8 -*-

# == Schema Information
# Schema version: 20090518160518
#
# Table name: triggers
#
#  id         :integer       not null, primary key
#  created_at :datetime      not null
#  updated_at :datetime      not null
#  device_id  :integer       not null, index_triggers_on_device_id
#  enable     :boolean       not null, index_triggers_on_enable
#  operator   :integer       not null
#  level      :integer       not null, index_triggers_on_level
#

# トリガ
class Trigger < ActiveRecord::Base
  has_many :email_actions
  belongs_to :device

  Operators = [
    [0, :eq, proc { |a, b| a == b }, "＝", "等しい"],
    [1, :ne, proc { |a, b| a != b }, "≠", "等しくない"],
    [2, :lt, proc { |a, b| a <  b }, "＜", "より小さい"],
    [3, :le, proc { |a, b| a <= b }, "≦", "以下"],
    [4, :gt, proc { |a, b| a >  b }, "＞", "より大きい"],
    [5, :ge, proc { |a, b| a >= b }, "≧", "以上"],
  ].freeze.each(&:freeze)

  OperatorsTable = Operators.inject(Hash.new({})) { |memo, (code, symbol, block, sign, desc)|
    memo[code] = {
      :symbol => symbol,
      :block  => block,
      :sign   => sign,
      :desc   => desc,
    }
    memo
  }.freeze.each(&:freeze)

  OperatorCodes = Operators.map(&:first).freeze

  validates_presence_of :device_id
  validates_presence_of :operator
  validates_presence_of :level
  validates_inclusion_of :operator, :in => OperatorCodes, :allow_nil => true
  validates_inclusion_of :level, :in => Energy::LevelRange, :allow_nil => true

  named_scope :enable, :conditions => {:enable => true}

  def self.operator_code_to_symbol(operator_code)
    return OperatorsTable[operator_code][:symbol]
  end

  def self.operator_code_to_sign(operator_code)
    return OperatorsTable[operator_code][:sign]
  end

  def self.operator_symbol_to_code(operator_symbol)
    @_ope_sym_code ||= Operators.inject({}) { |memo, (code, symbol, block, sign, desc)|
      memo[symbol] = code
      memo
    }
    return @_ope_sym_code[operator_symbol]
  end

  def operator_symbol
    return self.class.operator_code_to_symbol(self.operator)
  end

  def operator_sign
    return self.class.operator_code_to_sign(self.operator)
  end

  def match?(observed_level)
    block   = OperatorsTable[self.operator][:block]
    block ||= proc { |a, b| false }
    return block.call(observed_level, self.level)
  end

  def triggered?(first_level, second_level)
    return self.match?(first_level) && !self.match?(second_level)
  end

  def to_event_hash
    return {
      :trigger_operator => self.operator,
      :trigger_level    => self.level,
    }
  end
end
