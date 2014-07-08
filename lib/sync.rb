module Sync
  # Statuses of synchronizations
  WAITING = 0
  INPROCESS = 1
  ERROR = 2
  SUCCESS = 3
  FIXED = 4

  # Convertable extensions on Google Drive
  CONVERT_EXTENSIONS = %w(.doc .docx .html .txt .rtf .xls .xlsx .ods .csv .tsv .tab .ppt .pps .pptx)

  def self.transliterate(string)
    string
  end
end

require 'sync/email'
require 'sync/imap'
require 'sync/folder'
require 'sync/drive'
require 'sync/run'