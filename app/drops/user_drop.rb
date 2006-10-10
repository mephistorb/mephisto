class UserDrop < BaseDrop
  liquid_attributes << :login << :email
  def user() @source end
end
