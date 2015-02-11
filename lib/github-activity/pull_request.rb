module GithubActivity
  class PullRequest

    def initialize(repo, raw)
      @repo = repo
      @raw  = raw
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
      @issue_comments ||= begin
        $github_api_client.issue_comments(repo.full_name, number).map do |raw_comment|
          comment_key = '%s:comment:%s' % [ repo.cache_key, raw_comment.id ]
          $moneta.fetch(comment_key) do
            Comment.new(raw_comment).tap do |comment|
              $moneta[comment_key] = comment
            end
          end
        end
      end
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
