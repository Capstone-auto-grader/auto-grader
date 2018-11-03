module SessionsHelper
  def log_in(user)
  session[:user_id] = user.id
end

def current_user
  if session[:user_id]
    @current_user ||= User.find_by(id: session[:user_id])
  end
end

def logged_in?
 !current_user.nil?
end

def log_out
  session.delete(:user_id)
  @current_user = nil
end

def logged_in_user
 unless logged_in?
   store_location
   flash[:danger] = 'Please log in'
   redirect_to login_url
 end
end

def store_location
  session[:forwarding_url] = request.original_url if request.get?
end
end
