class LogFile
  include MongoMapper::Document

  key :sha512, String
  key :log_type, String
  key :key, String

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