module CommonHelpers

  def as_hash(hash)
    return nil if hash.nil?
    HashWithIndifferentAccess.new hash
  end

  def recreate_db
    res = `docker-compose exec mongo ./import/exec_script.sh gamescripter-test ./import/recreate_db.js`
    if $? != 0
      raise "Can not recreate the database (code #{$?}): \n #{res}"
    end
  end

end