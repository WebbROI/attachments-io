ActiveAdmin.register User do

  menu priority: 2

  filter :email
  filter :first_name
  filter :last_name
  filter :created_at

  action_item only: :show do
    link_to 'Fix synchronization', "/admin/users/#{user.id}/fix"
  end

  action_item only: :show do
    link_to 'Start synchronization', "/admin/users/#{user.id}/start"
  end

  index do
    selectable_column
    column :email
    column :first_name
    column :last_name

    column 'Last synchronization' do |user|
      if user.last_sync.nil?
        'Not yet'
      else
        Time.at(user.last_sync).to_formatted_s(:long)
      end
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

      row 'Last synchronization' do
        if user.last_sync.nil?
          'Not synchonized'
        else
          Time.at(user.last_sync).to_formatted_s(:long)
        end
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

  member_action :fix, method: :get do
    User.find(params[:id]).fix_sync
    redirect_to "/admin/users/#{params[:id]}", notice: 'Synchronization fixed!'
  end

  member_action :start, method: :get do
    User.find(params[:id]).start_synchronization
    redirect_to "/admin/users/#{params[:id]}", notice: 'Synchronization started!'
  end

  form do |f|
    f.inputs 'User Details' do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :picture
    end

    f.inputs 'Settings', for: [ :user_settings, f.object.user_settings || f.object.create_user_settings  ] do |fs|
      fs.input :convert_files
      fs.input :subject_in_filename
      fs.input :active
      fs.input :logging
    end

    f.actions
  end

  controller do
    def new
      @user = User.new
      @user.build_user_settings
    end

    def edit
      @user = User.find(params[:id])
      if @user.settings.nil?
        @user.build_user_settings
      end
    end

    def permitted_params
      params.permit(user: [ :first_name, :last_name, :email, :picture, :user_settings ])
    end

    def scoped_collection
      resource_class.includes(:emails)
    end
  end
end
