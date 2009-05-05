
# トリガ
class Trigger < ActiveRecord::Base
  belongs_to :device

  # TODO: EmailActionモデルとの関連を実装

  # TODO: device_idの存在を検証
  # TODO: operatorの存在を検証
  # TODO: operatorの範囲を検証
  # TODO: levelの存在を検証
  # TODO: levelの範囲を検証

  Operators = [
    [0, :eq, "＝", "等しい"],
    [1, :ne, "≠", "等しくない"],
    [2, :lt, "＜", "より小さい"],
    [3, :le, "≦", "以下"],
    [4, :gt, "＞", "より大きい"],
    [5, :ge, "≧", "以上"],
  ].freeze.each(&:freeze)

  OperatorsTable = Operators.inject(Hash.new({})) { |memo, (code, symbol, sign, desc)|
    memo[code] = {
      :symbol => symbol,
      :sign   => sign,
      :desc   => desc,
    }
    memo
  }.freeze.each(&:freeze)

  def self.operator_code_to_symbol(operator_code)
    return OperatorsTable[operator_code][:symbol]
  end

  def self.operator_code_to_sign(operator_code)
    return OperatorsTable[operator_code][:sign]
  end

  def self.operator_symbol_to_code(operator_symbol)
    @_ope_sym_code ||= Operators.inject({}) { |memo, (code, symbol, sign, desc)|
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

  # TODO: Eventモデルに変換するためのハッシュを生成するインスタンスメソッドを実装
end