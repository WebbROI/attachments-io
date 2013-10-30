ActiveAdmin.register UserSynchronization, as: 'Synchronization' do

  menu priority: 2

  filter :status
  filter :started_at
  filter :finished_at

  index do
    selectable_column

    column :user do |sync|
      link_to sync.user.email, "/admin/users/#{sync.user.id}"
    end

    column :email_count
    column :email_parsed

    column :status do |sync|
      sync.status_readable
    end

    column :started_at do |sync|
      Time.at(sync.started_at).to_formatted_s(:long)
    end

    column :finished_at do |sync|
      Time.at(sync.finished_at).to_formatted_s(:long)
    end

    actions
  end

  controller do
    def scoped_collection
      resource_class.includes(:user)
    end
  end

end
