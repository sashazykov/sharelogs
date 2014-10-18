class LogFileController < ApplicationController
  protect_from_forgery except: :create

  def create
    key = SecureRandom.urlsafe_base64(11)
    # secret_key = SecureRandom.urlsafe_base64(11)
    # sha512 = (Digest::SHA2.new(512) << secret_key).base64digest
    @log_file = LogFile.create key: key
    @log_file.store_log request.raw_post
    render text: log_file_url(key) + "\n"
  end

  def show
    @log_file = LogFile.find_by_key(params[:key])
  end
end
