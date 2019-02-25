module RequestHelpers

  def get_body
    begin
      return JSON.parse(last_response.body, :symbolize_names => true)
    rescue
      puts 'Non-json body:  ' + last_response.body.to_s
      return nil
    end
  end

  def as_json(hash = {})
    JSON.dump(hash)
  end

end