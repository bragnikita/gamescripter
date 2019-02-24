module ServiceHelpers

  def non_empty_value?(hash, key)
    hash.fetch(key, '') != ''
  end

end