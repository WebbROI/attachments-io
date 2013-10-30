ActiveAdmin.register UserSynchronizationFile, as: 'File' do

  menu label: 'Synchronizations Files', parent: 'Synchronizations'


  index do
    selectable_column

    column :filename

    column :type do |file|
      if file.extension
        file.extension.folder
      else
        Extension::OTHER
      end
    end

    column :size do |file|
      number_to_human_size(file.size)
    end

    actions
  end

  controller do
    def scoped_collection
      resource_class.includes(:user_synchronization, :extension)
    end
  end

end
