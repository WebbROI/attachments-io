ActiveAdmin.register Email, as: 'Email' do

  belongs_to :user
  menu false
  navigation_menu false

  index do
    selectable_column
    column :label
    column :subject

    column :attachments do |email|
      link_to pluralize(email.files.size, 'file'), admin_email_files_path(email)
    end

    column :date do |email|
      Time.at(email.date).to_formatted_s(:short)
    end

    actions
  end

  controller do
    def permitted_params
      params.permit user: [ :first_name, :last_name, :email, :picture ]
    end

    # TODO: fix it (слетают фильтры)
    #def scoped_collection
    #  resource_class.includes(:email_files)
    #end
  end
end
