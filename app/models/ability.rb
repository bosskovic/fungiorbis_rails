class Ability
  include CanCan::Ability

  def initialize(user)
    # return if user.nil?
    @user = user

    if @user.supervisor?
      can :manage, :all
    else
       can :show, User, :uuid => @user.uuid
    end
  end
end
