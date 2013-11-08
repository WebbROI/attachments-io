class UserSynchronizationFile < ActiveRecord::Base
  belongs_to :user_synchronization
  has_one :extension, foreign_key: 'extension', primary_key: 'ext'

  default_scope -> { order(created_at: :desc) }

  scope :audio, -> { where(ext: Extension.audio) }
  scope :documents, -> { where(ext: Extension.document) }
  scope :developers, -> { where(ext: Extension.developer) }
  scope :images, -> { where(ext: Extension.image) }
  scope :miscellaneous, -> { where(ext: Extension.miscellaneous) }
  scope :videos, -> { where(ext: Extension.video) }
  scope :others, -> { where('ext NOT IN (?)', Extension.all_array) }

  # TODO: remove this
  # scope :archives, -> { where(ext: Extension::ARCHIVES) }
  # scope :others, -> { where('ext NOT IN (?)', Extension::DOCUMENTS + Extension::IMAGES + Extension::ARCHIVES) }

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
