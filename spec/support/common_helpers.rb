module CommonHelpers

  def as_hash(hash)
    return nil if hash.nil?
    HashWithIndifferentAccess.new hash
  end

end