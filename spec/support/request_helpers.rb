module RequestHelpers

  def get_body
    JSON.parse(last_response.body, :symbolize_names => true)
  end

  def as_json(hash = {})
    JSON.dump(hash)
  end

end