class Extension < ActiveRecord::Base
  has_many :email_files, foreign_key: 'extension', primary_key: 'ext'

  AUDIO_FOLDER = 'Audio Files'
  DOCUMENT_FOLDER = 'Document Files'
  DEVELOPER_FOLDER = 'Developer Files'
  IMAGE_FOLDER = 'Image Files'
  MISCELLANEOUS_FOLDER = 'Miscellaneous Files'
  VIDEO_FOLDER = 'Video Files'

  OTHER = 'Miscellaneous Files'

  @extensions = {}

  def to_s
    extension
  end

  def self.all_hash
    return @extensions_hash if defined? @extensions_hash

    @extensions_hash = {}
    all.each do |ext|
      @extensions_hash[ext.extension] = ext
    end

    @extensions_hash
  end

  def self.all_array
    return @extensions_all if defined? @extensions_all

    @extensions_all = []
    all.each do |ext|
      @extensions_all << ext.extension
    end

    @extensions_all
  end

  def self.load_by_folder(folder)
    return @extensions[folder] if @extensions[folder]

    @extensions[folder] = []
    find_all_by_folder(folder).each do |ext|
      @extensions[folder] << ext.extension
    end

    @extensions[folder]
  end

  def self.audio
    load_by_folder(AUDIO_FOLDER)
  end

  def self.document
    load_by_folder(DOCUMENT_FOLDER)
  end

  def self.developer
    load_by_folder(DEVELOPER_FOLDER)
  end

  def self.image
    load_by_folder(IMAGE_FOLDER)
  end

  def self.miscellaneous
    load_by_folder(MISCELLANEOUS_FOLDER)
  end

  def self.video
    load_by_folder(VIDEO_FOLDER)
  end

end
