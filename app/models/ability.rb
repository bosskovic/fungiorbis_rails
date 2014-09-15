class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      @user = user

      if @user.supervisor?
        can :manage, :all
      else
        can [:show, :update], User, uuid: @user.uuid
        can :activate, User, uuid: @user.uuid
      end
    end

    can [:index, :show], Species
    can [:index, :show], Reference
  end

end
