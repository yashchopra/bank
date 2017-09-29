json.extract! tran, :id, :amount, :credit, :balance, :user_id, :account_id, :created_at, :updated_at
json.url tran_url(tran, format: :json)
