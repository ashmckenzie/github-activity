module GithubActivity
  module RepoLookup
    class Exact

      def initialize(organisation_name, repo_names)
        @organisation_name = organisation_name
        @repo_names = repo_names
      end

      def lookup
        repo_names.map do |repo_name|
          full_repo_name = '%s/%s' % [ organisation_name, repo_name ]
          raw_repo = $github_api_client.repository(full_repo_name)
          Repo.new(raw_repo) unless raw_repo.empty?
        end.compact
      end

      private

        attr_reader :organisation_name, :repo_names

    end
  end
end
