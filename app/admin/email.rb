ActiveAdmin.register Email, as: 'Email' do

  menu priority: 3

  index do
    selectable_column
    column :label
    column :subject

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
