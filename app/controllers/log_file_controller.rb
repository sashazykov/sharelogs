class LogFileController < ApplicationController
  protect_from_forgery except: :create

  def create
    key = SecureRandom.urlsafe_base64(11)
    # secret_key = SecureRandom.urlsafe_base64(11)
    # sha512 = (Digest::SHA2.new(512) << secret_key).base64digest
    @log_file = LogFile.new key: key, log_type: params[:log_type]
    if @log_file.save
      @log_file.store_log request.raw_post
      render text: log_file_url(key) + "\n"
    else
      render text: @log_file.errors.full_messages.join("\n") + "\n"
    end
  end

  def show
    @log_file = LogFile.find_by_key(params[:key])
    if @log_file
      respond_to do |format|
        format.html
        format.log { render text: @log_file.raw_log }
      end
    else
      render text: 'Not Found', status: 404
    end
  end
end
