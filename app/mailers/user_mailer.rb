class UserMailer < ApplicationMailer

    def password_reset(user, request)
        @user = user
        @request = request
        mail to: @user.email, subject: "Password reset", from: 'noreply@autograder.me'
    end

    def welcome_email(user, request)
        @user = user
        @request = request
        mail to: @user.email, subject: "Welcome to AutoGrader", from: 'noreply@autograder.me'
    end

end