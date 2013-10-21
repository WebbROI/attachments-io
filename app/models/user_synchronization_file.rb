class UserSynchronizationFile < ActiveRecord::Base
  has_one :extension, foreign_key: 'extension', primary_key: 'ext'

  default_scope -> { order(created_at: :desc) }

  scope :documents, -> { where(ext: Extension::DOCUMENTS) }
  scope :images, -> { where(ext: Extension::IMAGES) }
  scope :archives, -> { where(ext: Extension::ARCHIVES) }
  scope :others, -> { where('ext NOT IN (?)', Extension::DOCUMENTS + Extension::IMAGES + Extension::ARCHIVES) }

  def load_extension
    return @extension if defined?(@extension)
    extensions = Extension.all_hash
    @extension = extensions[ext]
  end

  def file_type
    if load_extension
      load_extension.file_type
    else
      Extension::OTHER
    end
  end
end
