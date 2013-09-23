module Google
  class User
    attr_accessor :login, :first_name, :last_name

    def self.all(domain)
      feed = Google::Client.get("https://apps-apis.google.com/a/feeds/#{domain}/user/2.0")

      feed.elements.collect('//entry') { |e| new_from_entry(e) }
    end

    def initialize(options = {})

    end

    private

    def self.new_from_entry(entry)
      puts entry.inspect
    end
  end
end