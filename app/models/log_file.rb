class LogFile
  include MongoMapper::Document

  LOG_TYPES = %w(rails)

  key :sha512, String
  key :log_type, String, :in => LOG_TYPES
  key :key, String, :required => true

  before_destroy :destroy_log

  def grid
    @grid ||= Mongo::Grid.new(MongoMapper.database)
  end

  def store_log log, sanitized = true
    if sanitized
      log = log.gsub(/\/(Users|home)\/[\w\d]+\//, '/home/user/')
    end
    grid.delete(id)
    grid.put(log, {
      :_id => id
    })
  end

  def file
    grid.get(id)
  end

  def raw_log
    @raw_log ||= file.read
  end

  private

  def destroy_log
    grid.delete(id)
  end

end