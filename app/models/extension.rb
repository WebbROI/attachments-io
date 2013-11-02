class Extension < ActiveRecord::Base
  has_many :user_synchronization_files, foreign_key: 'extension', primary_key: 'ext'

  DOCUMENTS = %w[.doc .docx .vcf .pdf]
  IMAGES = %w[.jpg .jpeg .png .gif]
  ARCHIVES = %w[.rar .zip]
  PDF = '.pdf'

  OTHER = 'Miscellaneous Files'


  def self.all_hash
    return @extensions_hash if defined? @extensions_hash
    @extensions ||= all

    @extensions_hash = Hash.new
    @extensions.each do |extension|
      @extensions_hash[extension.extension] = extension
    end

    @extensions_hash
  end

end
