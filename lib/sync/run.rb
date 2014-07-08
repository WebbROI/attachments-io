class Sync::Run

  DEFAULT_PARAMS = {
    puub: true,
    debug: false,
    logging: false
  }

  def initialize(user_id, params = {})
    @user = User.find(user_id)
    @user_settings = @user.settings
    @synchronization = @user.synchronization
    @params = params.reverse_merge(DEFAULT_PARAMS)

    @imap = Sync::IMAP.new(@user, @params)
    @drive = Sync::Drive.new(@user, @params)

    run
  ensure
    @synchronization.waiting!
  end

  private

  def run
    @emails = @imap.get_emails

    if @emails.empty?
      finish_ok
      return
    end

    @folders = @drive.get_folders
    process_labels_folders

    @emails.each do |label, emails|
    end

    puts @folders.title
    puts @folders.title
    puts @folders.title
    
    finish_ok
  end

  def process_labels_folders
    @emails.each_key do |label|
      if @folders[label.to_s].nil?
        label_folder = @user.api.create_folder(title: label, parent_id: @folders.id).data
        @folders.add_sub_folder(Sync::Folder.new(label_folder))
      end
    end
  end

  def finish_ok
    @synchronization.waiting!
  end
end