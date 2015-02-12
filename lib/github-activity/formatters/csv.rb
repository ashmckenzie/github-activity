module GithubActivity
  module Formatters
    class CSV

      HEADERS = %w( repo_name timestamp name email message github_url github_pr_url jira_urls )

      def initialize(filename)
        @file = File.open(filename, 'w')
      end

      def begin!
        write_header
      end

      def render(repo, commit)
        line = [
          repo.full_name,
          commit.timestamp,
          commit.author.name,
          commit.author.email,
          commit.message,
          commit.github_url,
          commit.pull_request.url,
          commit.jira_tickets.map(&:url).join(' ')
        ]
        file.puts(line.join(','))
      end

      def finish!
        file.close
      end

      private

        attr_reader :file

        def write_header
          file.puts(HEADERS.join(','))
          file.flush
        end

    end
  end
end
