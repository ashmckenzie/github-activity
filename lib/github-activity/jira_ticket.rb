module GithubActivity
  class JiraTicket

    ZENDESK_JIRA_BASE_URL = 'https://zendesk.atlassian.net/browse'

    attr_reader :number

    def initialize(number)
      @number = number
    end

    def url
      "#{ZENDESK_JIRA_BASE_URL}/#{number}"
    end

    def self.extract_jira_ticket_numbers_from(input)
      return [] if input.nil?
      input.scan(/\b([a-zA-Z]+-\d+)\b/).flatten.map { |x| x.strip.upcase }.uniq
    end

  end
end
