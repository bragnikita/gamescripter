module ServiceHelpers
  def check(query_result)
    if query_result.is_a? Mongo::Operation::Result
      raise 'MongoDB failed' unless query_result.successful?
    end
    query_result
  end

  def non_empty_value?(hash, key)
    hash.fetch(key, '') != ''
  end

  def build_update_statement(hash, *keys)
    stmt = {}
    keys.each do |key|
      stmt[key] = hash[key] if hash.has_key?[:key]
    end
    stmt
  end
end