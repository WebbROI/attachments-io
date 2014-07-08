class Sync::Drive
  DEFAULT_PARAMS = {
    drive: {
      default_folder: 'ATTACHMENT_DEV'
    }
  }

  def initialize(user, params = {})
    @user   = user
    @api    = @user.api
    @params = params.reverse_merge(DEFAULT_PARAMS)
  end

  def get_folders
    drive_folders = []
    default_folder = nil

    # load all folders
    @api.load_files(is_folder: true).data.items.each do |folder|
      drive_folders << Sync::Folder.new(folder)
    end

    # find default folder
    drive_folders.each do |folder|
      if folder.title == @params[:drive][:default_folder] && folder.is_root?
        default_folder = folder
        break
      end
    end

    # create default folder if not exist
    if default_folder.nil?
      default_folder = @api.create_folder(title: @params[:drive][:default_folder]).data
      return Sync::Folder.new(default_folder)
    end

    # create dom of folders
    drive_folders.delete(default_folder)
    drive_folders.each do |folder|
      default_folder = create_hierarchy(default_folder, drive_folders)
    end

    default_folder
  end

  private
  def create_hierarchy(parent_folder, children_folders)
    children_folders.each do |children_folder|
      if parent_folder.parent?(children_folder)
        children_folder = create_hierarchy(children_folder, children_folders)
        parent_folder.add_sub_folder(children_folder)
      end
    end

    parent_folder
  end
end