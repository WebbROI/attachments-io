class DevController < ApplicationController
  require 'synchronization/process'

  before_filter :authenticate_user!, only: :compare_files

  def debug
    Synchronization::Process.add(rand(100))

    render text: 'success :)'
  end

  def debug2
    render text: Synchronization::Process.list
  end

  def flush_all
    User.destroy_all
    redirect_to root_path, flash: { success: 'Success!' }
  end

  def compare_files
    user = current_user
    user_api = user.api

    @attachments_from_gmail = []
    @attachments_from_drive = {}

    # get attachments from GMail
    imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)
    imap.authenticate('XOAUTH2', user.email, user_api.tokens[:access_token])

    emails = {}
    imap.list('', '%').each do |label|
      next unless label.attr.find_index(:Noselect).nil?

      imap.select(label.name)
      emails_ids = imap.search('X-GM-RAW has:attachment')

      next if emails_ids.empty?

      emails[label.name] = emails_ids
    end

    emails.each do |label, emails_ids|
      imap.select(label)

      emails_ids.each do |email_id|
        mail = Mail.read_from_string(imap.fetch(email_id, 'RFC822')[0].attr['RFC822'])

        mail.attachments.each do |attachment|
          @attachments_from_gmail << attachment.filename
        end
      end
    end

    # get attachments form Drive
    all_files = user_api.load_files(is_folder: false).data.items
    all_files.each do |file|
      @attachments_from_drive[file.title] = file.alternate_link
    end
  end
end