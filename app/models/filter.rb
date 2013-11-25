class Filter < ActiveRecord::Base
  belongs_to :user

  serialize :images_extensions
  serialize :documents_extensions

  def update_extensions(params)

    if params[:images_extensions]
      update_attribute(:images_extensions, params[:images_extensions].to_a)
    end

    if params[:documents_extensions]
      update_attribute(:documents_extensions, params[:documents_extensions].to_a)
    end
  end
end
