class Sync::Folder
  def initialize(folder)
    @folder = folder
    @sub_folders = {}
  end

  def is_root?
    !@folder.parents.empty? && @folder.parents[0].is_root
  end

  def parent?(folder)
    is_parent = false

    folder.parents.each do |parent|
      if parent.id == @folder.id
        is_parent = true
        break
      end
    end unless folder.parents.empty?

    is_parent
  end

  #
  # SUB FOLDERS
  #
  def sub_folders
    @sub_folders.values
  end

  def [](folder_name)
    @sub_folders[folder_name]
  end

  def add_sub_folder(folder)
    @sub_folders[folder.title] = folder
  end

  def remove_sub_folder(folder_name)
    @sub_folders.delete(folder_name)
  end

  # load methods from folder
  def method_missing(method, *args, &block)
    if @folder.respond_to?(method)
      @folder.send(method, *args)
    else
      super
    end
  end
end