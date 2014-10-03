class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  ## Database authenticatable
  field :email,              :type => String

  index({email: 1}, {unique: true})
end
