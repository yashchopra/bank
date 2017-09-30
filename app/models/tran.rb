class Tran < ApplicationRecord
	belongs_to :account
	enum credit: [:credit, :debit, :transfer]
end
