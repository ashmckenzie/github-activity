module GithubActivity
  class Commit

    PER_PAGE = 100

    attr_reader :repo

    def initialize(repo, raw)
      @repo = repo
      @raw  = raw
    end

    def self.find(repo, sha)
      $moneta.fetch(lookup_key(repo, sha)) do |key|
        raw_commit = $github_api_client.commit(repo.full_name, sha)
        new(repo, raw_commit).tap { |c| $moneta[key] = c }
      end
    end

    def self.find_between(repo, date_from, date_to)
      request = Request.new
      query = proc { $github_api_client.commits_between(repo.full_name, date_from, date_to, per_page: PER_PAGE) }
      request.get(query).map do |raw_commit|
        $moneta.fetch(lookup_key(repo, raw_commit.sha)) { |key| new(repo, raw_commit).tap { |c| $moneta[key] = c } }
      end
    end

    def self.lookup_key(repo, sha)
      '%s:commit:%s' % [ repo.cache_key, sha ]
    end

    def sha
      @sha ||= raw.sha
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

    def pull_request
      @pull_request ||= begin
        if pull_request_number
          PullRequest.find(repo, pull_request_number).tap do |pr|
            pr.cache_commits!(parent_commits)
          end
        else
          NullPullRequest.new
        end
      end
    end

    def jira_tickets
      @jira_tickets ||= all_jira_ticket_numbers.uniq.map { |ticket_number| JiraTicket.new(ticket_number) }
    end

    def to_s
      '%s %s %s' % [ timestamp, sha, message ]
    end

    def pull_request_commit_link_key
      '%s:pull-request-commit-links:%s' % [ repo.cache_key, sha ]
    end

    private

      attr_reader :raw

      def parent_commits
        @parent_commits ||= raw.parents.map { |parent_commit| self.class.find(repo, parent_commit.sha) }
      end

      def pull_request_regex
        @pull_request_regex ||= /^Merge pull request #(?<number>\d+) /
      end

      def pull_request_number
        commit_pull_request_number || linked_pull_request_number
      end

      def commit_pull_request_number
        @commit_pull_request_number ||= message.match(pull_request_regex) { |match| match[:number] }
      end

      def linked_pull_request_number
        $moneta[pull_request_commit_link_key]
      end

      def all_jira_ticket_numbers
        (jira_ticket_numbers + pull_request.jira_ticket_numbers)
      end

      def jira_ticket_numbers
        @jira_ticket_numbers ||= JiraTicket.extract_jira_ticket_numbers_from(message)
      end

  end
end
