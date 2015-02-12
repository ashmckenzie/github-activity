module GithubActivity
  class PullRequest

    def initialize(repo, raw)
      @repo = repo
      @raw  = raw
    end

    def self.find(repo, pull_request_number)
      key = pull_request_lookup_key(repo, pull_request_number)
      $moneta.fetch(key) do
        raw_pull_request = $github_api_client.pull_request(repo.full_name, pull_request_number)
        new(repo, raw_pull_request).tap { |pr| $moneta[key] = pr }
      end
    end

    def self.pull_request_lookup_key(repo, sha)
      '%s:pull-request:%s' % [ repo.cache_key, sha ]
    end

    def self.find_comments(repo, pull_request_number)
      $github_api_client.issue_comments(repo.full_name, pull_request_number).map do |raw_comment|
        key = issue_comments_lookup_key(repo, pull_request_number)
        $moneta.fetch(key) do
          Comment.new(raw_comment).tap { |c| $moneta[key] = c }
        end
      end
    end

    def self.issue_comments_lookup_key(repo, id)
      '%s:comment:%s' % [ repo.cache_key, id ]
    end

    def number
      @number ||= raw.number
    end

    def url
      @url ||= raw.html_url
    end

    def title
      @title ||= raw.title
    end

    def description
      @description ||= raw.body
    end

    def branch
      @branch ||= raw.head.ref
    end

    def issue_comments
      @issue_comments ||= self.class.find_comments(repo, number)
    end

    def jira_ticket_numbers
      @jira_ticket_numbers ||= begin
        inputs = [ url, title, description, branch ] + issue_comments.map(&:body)
        inputs.map do |input|
          JiraTicket.extract_jira_ticket_numbers_from(input)
        end.flatten.uniq
      end
    end

    private

      attr_reader :raw, :repo

  end

  NullPullRequest = Naught.build do |config|
    config.mimic PullRequest

    def jira_ticket_numbers
      []
    end
  end
end
