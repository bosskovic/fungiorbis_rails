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

    can :show, :habitats
    can :show, :substrates
    can :show, :species_systematics
    can :show, :stats

    can [:index, :show], Species
    can [:index, :show], Reference
    can [:index, :show], Characteristic
    can [:index, :show], Location
    can [:index, :show], Specimen
  end

end
