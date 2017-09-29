class Account < ApplicationRecord
	belongs_to :user
	has_many :trans
	accepts_nested_attributes_for :trans
end
