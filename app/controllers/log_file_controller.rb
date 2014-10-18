class LogFileController < ApplicationController
  protect_from_forgery except: :create

  def create
    @log_file = LogFile.create
    render text: log_file_url(@log_file.sha512)
  end

  def show
  end
end
