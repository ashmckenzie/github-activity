module GithubActivity
  module RepoLookup
    class Regex

      PER_PAGE = 100

      attr_reader :repos

      def initialize(organisation_name, regex)
        @organisation_name = organisation_name
        @regex = Regexp.new(regex)
      end

      def lookup
        repos = []
        request.get(lookup_query) do |raw_repos|
          raw_repos.each do |raw_repo|
            repos << Repo.new(raw_repo) if raw_repo[:name].match(regex)
          end
        end
        repos
      end

      private

        attr_reader :organisation_name, :regex
        attr_writer :repos

        def request
          @request ||= Request.new
        end

        def lookup_query
          proc { $github_api_client.organization_repositories(organisation_name, per_page: PER_PAGE) }
        end
    end
  end
end
