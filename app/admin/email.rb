ActiveAdmin.register Email, as: 'Email' do

  belongs_to :user

  index do
    selectable_column
    column :label
    column :subject

    column :files do |email|
      link_to pluralize(email.files.size, 'file'), admin_email_files_path(email)
    end

    column :date do |email|
      Time.at(email.date).to_formatted_s(:short)
    end

    actions
  end

  show do
    attributes_table do
      row :label
      row :subject
      row :from
      row :to
    end

    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :label
      f.input :subject
      f.input :from
      f.input :to
    end

    f.actions
  end

  controller do
    def permitted_params
      params.permit email: [ :label, :subject, :from, :to ]
    end
  end
end
