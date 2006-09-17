class UserMailer < ActionMailer::Base
  include ActionController::UrlWriter
  @@mail_from = nil
  mattr_accessor :mail_from

  def forgot_password(user)
    setup_email(user)
    @subject += 'Request to change your password'
    @body[:url]  = url_for :controller => :account, :action => :activate, :id => user.token
  end

  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "#{@@mail_from}"
      @subject     = "#{default_url_options[:host]}: "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
