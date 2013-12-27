ActiveAdmin.register EmailFile, as: 'File' do

  menu priority: 4

  index do
    selectable_column
    column :filename

    column :link do |file|
      link_to 'Google Drive', file.link, target: '_blank'
    end

    column 'Status' do |file|
      if file.status == EmailFile::UPLOADED
        'Uploaded'
      elsif file.status == EmailFile::ALREADY_UPLOADED
        'Already uploaded'
      end
    end

    column 'Uploaded at' do |file|
      Time.at(file.created_at).to_formatted_s(:short)
    end

    actions
  end

  show do
    attributes_table do
      row :filename
      row :size
      row :link
      row :status do |file|
        if file.status == EmailFile::UPLOADED
          'Uploaded'
        elsif file.status == EmailFile::ALREADY_UPLOADED
          'Already uploaded'
        end
      end
    end

    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :filename
      f.input :link
      f.input :status
    end

    f.actions
  end

  controller do
    def permitted_params
      params.permit file: [:filename, :size, :link, :status]
    end
  end
end
