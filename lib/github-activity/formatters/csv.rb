module GithubActivity
  module Formatters
    class CSV

      HEADERS = %w{ repo_name timestamp name email message github_url jira_urls }

      def initialize filename
        @file = File.open(filename, 'w')

        write_header
      end

      def render repo_name, commit
        line = [
          repo_name,
          commit.timestamp,
          commit.author.name,
          commit.author.email,
          commit.message,
          commit.github_url,
          commit.jira_urls.join(' ')
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
