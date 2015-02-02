module GithubActivity
  module Formatters
    class Human

      def render commit
        print_line

        puts "#{commit.author.name} (#{commit.author.email}) #{commit.timestamp}"
        puts "GitHub URL: #{commit.github_url}"
        puts "JIRA URL(s): #{commit.jira_urls.join(', ')}" unless commit.jira_urls.empty?

        puts "\n#{commit.message}"
      end

      def print_line
        puts '-' * 96
      end
    end
  end
end
