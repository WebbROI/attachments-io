module Google
  class Contact
    attr_accessor :full_name, :first_name, :last_name, :email, :company, :title, :notes

    def self.all(email)
      feed = Google::Client.get('https://www.google.com/m8/feeds/contacts/default/full', {
          'xoauth_requestor_id' => email
      }, '3.0')

      feed.elements.collect('//entry') do |entry|
        new(
            full_name: entry.elements['gd:name'].elements['gd:fullName'].text,
            first_name: entry.elements['gd:name'].elements['gd:givenName'].text
        )
      end
    end

    def initialize(options = {})
      @full_name = options[:full_name]
      @first_name = options[:first_name]

      puts @full_name
      puts @first_name
    end
  end
end