#encoding:utf-8

class User < UniObjects::UniVerse

  include ActiveModel::AttributeMethods
  include ActiveModel::Conversion
  extend  ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include ActiveModel::Callbacks

  def persisted?
    self.id.present?
  end

end
