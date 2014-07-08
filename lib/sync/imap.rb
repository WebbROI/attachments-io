class Sync::IMAP
  DEFAULT_PARAMS = {
    imap: {
      url: 'imap.gmail.com',
      port: 993
    }
  }

  NOSELECT = :Noselect

  def initialize(user, params = {})
    @user   = user
    @params = params.reverse_merge(DEFAULT_PARAMS)

    @connection = Net::IMAP.new(@params[:imap][:url], @params[:imap][:port], usessl = true, certs = nil, verify = false)
    @connection.authenticate('XOAUTH2', @user.email, @user.api.tokens[:access_token])
  end

  def get_emails
    emails = {}
    search_query = 'X-GM-RAW "has:attachment'

    if @params[:before_date]
      search_query += " before:#{@params[:before_date].to_i}"
    end

    if @params[:after_date]
      search_query += " after:#{@params[:after_date].to_i}"
    end

    search_query += '"'

    get_labels.each do |label|
      next if label.attr.include?(NOSELECT)

      @connection.examine(label.name)
      label_emails = @connection.search(search_query, 'UTF-8')

      next if label_emails.empty?

      emails[label.name] = []
      label_emails.each do |email_id|
        # email = @connection.fetch(email_id, 'RFC822')
        # email = Mail.read_from_string(email[0].attr['RFC822'])

        emails[label.name] << Sync::Email.new(email_id)
      end
    end

    emails
  end

  def get_labels
    labels = []

    @connection.list('', '%').to_a.each do |label|
      label.name = Sync::transliterate(label.name)
      labels << label
    end
    
    labels
  end
end