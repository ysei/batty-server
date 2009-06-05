# == Schema Information
# Schema version: 20090529051529
#
# Table name: energies
#
#  id             :integer       not null, primary key
#  created_at     :datetime      not null
#  device_id      :integer       not null, index_energies_on_device_id
#  observed_level :integer       not null
#  observed_at    :datetime      not null, index_energies_on_observed_at
#

# エネルギー
class Energy < ActiveRecord::Base
  has_many :events, :dependent => :nullify
  belongs_to :device

  LevelRange = 0..100

  validates_presence_of :observed_level
  validates_presence_of :observed_at
  validates_inclusion_of :observed_level, :in => LevelRange, :allow_nil => true

  def self.cleanup(device, limit)
    recent = device.energies.all(
      :order  => "energies.observed_at DESC, energies.id DESC",
      :limit  => limit)
    self.destroy_all(["(energies.device_id = ?) AND (energies.id NOT IN (?))", device.id, recent.map(&:id)])
  end

  def to_event_hash
    return {
      :observed_level => self.observed_level,
      :observed_at    => self.observed_at,
    }
  end
end
