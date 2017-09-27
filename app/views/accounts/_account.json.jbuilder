json.extract! account, :id, :acctype, :accnumber, :accrouting, :user_id, :created_at, :updated_at
json.url account_url(account, format: :json)
