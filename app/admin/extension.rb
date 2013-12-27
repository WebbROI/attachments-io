ActiveAdmin.register Extension do

  menu priority: 5

  filter :extension
  filter :file_type
  filter :folder
  filter :sub_folder

  index do
    selectable_column

    column :extension
    column :file_type
    column :folder
    column :sub_folder

    actions
  end

  controller do
    def permitted_params
      params.permit extension: [ :extension, :file_type, :folder, :sub_folder ]
    end
  end
end
