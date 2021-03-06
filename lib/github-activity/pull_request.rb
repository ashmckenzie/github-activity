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

    def self.pull_request_lookup_key(repo, number)
      '%s:pull-request:%s' % [ repo.cache_key, number ]
    end

    def pull_request_lookup_key
      self.class.pull_request_lookup_key(repo, number)
    end

    def self.find_comments(repo, pull_request_number)
      # TODO: Why #pull_request_comments doesn't work?
      $github_api_client.issue_comments(repo.full_name, pull_request_number).map do |raw_comment|
        key = comments_lookup_key(repo, raw_comment.id)
        $moneta.fetch(key) { Comment.new(raw_comment).tap { |c| $moneta[key] = c } }
      end
    end

    def self.comments_lookup_key(repo, id)
      '%s:comment:%s' % [ repo.cache_key, id ]
    end

    def cache_commits!(parent_commits)
      (parent_commits + commits).each do |commit|
        $moneta.fetch(commit.pull_request_commit_link_key) { |key| $moneta[key] = number }
      end
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

    def comments
      @comments ||= self.class.find_comments(repo, number)
    end

    def jira_ticket_numbers
      @jira_ticket_numbers ||= begin
        numbers = jira_ticket_numbers_in_detail
        numbers +=  jira_ticket_numbers_in_comments if numbers.empty?
        numbers
      end
    end

    def commits
      @commits ||= begin
        $github_api_client.pull_request_commits(repo.full_name, number).map do |raw_commit|
          key = Commit.lookup_key(repo, raw_commit.sha)
          $moneta.fetch(key) do
            Commit.new(repo, raw_commit).tap { |c| $moneta[key] = c }
          end
        end
      end
    end

    private

      attr_reader :raw, :repo

      def jira_ticket_numbers_in_detail
        extract_jira_tickets([ url, title, description, branch ])
      end

      def jira_ticket_numbers_in_comments
        extract_jira_tickets(comments.map(&:body))
      end

      def extract_jira_tickets(inputs)
        inputs.map { |input| JiraTicket.extract_jira_ticket_numbers_from(input) }.flatten.uniq
      end
  end

  NullPullRequest = Naught.build do |config|
    config.mimic PullRequest

    def jira_ticket_numbers
      []
    end
  end
end
