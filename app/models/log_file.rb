class LogFile
  include MongoMapper::Document

  key :sha512, String
  key :log_type, String

  before_save :generate_password, :if => -> { sha512.blank? }

  def grid
    @grid ||= Mongo::Grid.new(MongoMapper.database)
  end

  def store_log file
    grid.delete(id)
    grid.put(file, {
      :_id => id
    })
  end

  def get_file
    grid.get(id)
  end

  def rewrite_sha514 password
    sha512 = (Digest::SHA2.new(512) << password).base64digest
  end

  def generate_password
    password = SecureRandom.urlsafe_base64(11)
    rewrite_sha514 password
    return password
  end

end