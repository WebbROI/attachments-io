ActiveAdmin.register User do

  menu priority: 1

  filter :email
  filter :first_name
  filter :last_name
  filter :created_at

  index do
    selectable_column
    column :email
    column :first_name
    column :last_name
    column 'Synchronizations' do |user|
      #raw "<pre>#{user.synchronizations.started_at}</pre>"
    end
    column 'Registered at', :created_at
    actions
  end

  show do |user|
    attributes_table do
      row :first_name
      row :last_name
      row :email
      row :picture do
        image_tag(user.picture)
      end

      if user.profile.plus
        row 'Google Plus' do
          link_to "#{user.first_name} #{user.last_name}", user.profile.plus, target: '_blank'
        end
      end

      if user.profile.twitter
        row 'Twitter' do
          link_to "#{user.first_name} #{user.last_name}", user.profile.twitter, target: '_blank'
        end
      end

      if user.profile.facebook
        row 'Facebook' do
          link_to "#{user.first_name} #{user.last_name}", user.profile.facebook, target: '_blank'
        end
      end
    end

    active_admin_comments
  end

  form do |f|
    f.inputs 'User Details' do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :picture
    end

    f.actions
  end

  controller do
    def permitted_params
      params.permit user: [ :first_name, :last_name, :email, :picture ]
    end

    def scoped_collection
      resource_class.includes(:user_synchronizations)
    end
  end
end
