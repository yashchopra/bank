class Account < ApplicationRecord
	belongs_to :user
	has_many :trans, dependent: :delete_all
	accepts_nested_attributes_for :trans
end
