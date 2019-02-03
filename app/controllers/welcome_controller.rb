class WelcomeController < ApplicationController
  def index
    redirect_to courses_path if logged_in?
  end
end
