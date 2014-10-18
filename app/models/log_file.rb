class LogFile
  include MongoMapper::Document

  LOG_TYPES = %w(rails)

  key :sha512, String
  key :log_type, String, :in => LOG_TYPES
  key :key, String, :required => true

  def grid
    @grid ||= Mongo::Grid.new(MongoMapper.database)
  end

  def store_log file
    grid.delete(id)
    grid.put(file, {
      :_id => id
    })
  end

  def raw_log
    grid.get(id).read
  end

end