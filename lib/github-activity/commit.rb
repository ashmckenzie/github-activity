module GithubActivity
  class Commit

    ZENDESK_JIRA_BASE_URL = 'https://zendesk.atlassian.net/browse'

    def initialize raw
      @raw = raw
    end

    def timestamp
      @timestamp ||= raw.commit.author.date
    end

    def author
      @author ||= raw.commit.author
    end

    def message
      @message ||= raw.commit.message.strip.gsub(/\n/, ' -- ').gsub(/,/, '')
    end

    def github_url
      @url ||= raw.html_url
    end

    def jira_urls
      @jira_urls ||= begin
        message.scan(/(\w+-\d+)/).flatten.map { |x| x.strip.upcase }.uniq.map do |ticket_number|
          "#{ZENDESK_JIRA_BASE_URL}/#{ticket_number}"
        end
      end
    end

    def inspect
      {
        name: author.name,
        email: author.email,
        message: message,
        github_url: github_url,
        jira_urls: jira_urls
      }
    end

    private

      attr_reader :raw

  end
end
