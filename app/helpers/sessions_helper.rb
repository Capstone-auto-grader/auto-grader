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

  def require_login
    unless logged_in?
      store_location
      redirect_to '/login'
    end
  end

  def is_superuser(course_id)
    current_course = Course.find course_id
    (current_course.professors.exists? current_user.id)
  end

  def is_ta(course_id)
    current_course = Course.find course_id
    (current_course.tas.exists? current_user.id)
  end
  def is_student(course_id)
    current_course = Course.find course_id
    (current_course.students.exists? current_user.id)
  end
end
