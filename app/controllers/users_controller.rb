class UsersController < ApplicationController
  def index
    @users = User.where(email: 'matt@matthoran.com')
  end
end
