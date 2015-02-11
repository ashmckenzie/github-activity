module GithubActivity
  class Commit

    attr_reader :repo

    def initialize(repo, raw)
      @repo = repo
      @raw  = raw
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

    def pull_request_number
      commit_pull_request_number || parent_commit_pull_request_number
    end

    def pull_request
      @pull_request ||= begin
        if pull_request_number
          raw_pull_request = $github_api_client.pull_request(repo.full_name, pull_request_number)
          PullRequest.new(repo, raw_pull_request)
        else
          NullPullRequest.new
        end
      end
    end

    def jira_ticket_numbers_from_commit
      @jira_ticket_numbers_from_commit ||= JiraTicket.extract_jira_ticket_numbers_from(message)
    end

    def jira_ticket_numbers_from_pull_request
      @jira_ticket_numbers_from_pull_request ||= pull_request.jira_ticket_numbers
    end

    def jira_tickets
      @jira_tickets ||= begin
        (jira_ticket_numbers_from_commit + jira_ticket_numbers_from_pull_request).uniq.map do |ticket_number|
          JiraTicket.new(ticket_number)
        end
      end
    end

    def parent_commits
      @parent_commits ||= begin
        raw.parents.map do |parent_commit|
          commit_key = '%s:commit:%s' % [ repo.cache_key, parent_commit.sha ]
          $moneta.fetch(commit_key) do |sha|
            raw_commit = $github_api_client.commit(repo.full_name, parent_commit.sha)
            Commit.new(repo, raw_commit).tap do |commit|
              $moneta[commit_key] = commit
            end
          end
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

      def pull_request_regex
        @pull_request_regex ||= /^Merge pull request #(?<number>\d+) /
      end

      def commit_pull_request_number
        @commit_pull_request_number ||= message.match(pull_request_regex) { |match| match[:number] }
      end

      def parent_commit_pull_request_number
        @parent_commit_pull_request_number ||= begin
          commit = parent_commits.detect { |c| !c.commit_pull_request_number.nil? }
          commit ? commit.commit_pull_request_number : nil
        end
      end

  end
end
