class UserMailer < ApplicationMailer

    def password_reset(user)
        @user = user
        mail to: user.email, subject: "Password reset", from: 'noreply@autograder.me'
    end

end