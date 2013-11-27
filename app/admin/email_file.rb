ActiveAdmin.register EmailFile, as: 'File' do

  belongs_to :email
  menu false
  navigation_menu false

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
  end
end
