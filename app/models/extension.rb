class Extension < ActiveRecord::Base

  DOCUMENTS = %w[.doc .docx]
  IMAGES = %w[.jpg .jpeg .png .gif]
  ARCHIVES = %w[.rar .zip]
  PDF = '.pdf'

  OTHER = 'Other type'


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
