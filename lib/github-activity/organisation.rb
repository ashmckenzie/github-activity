module GithubActivity
  class Organisation

    PER_PAGE = 100

    def initialize name
      @name = name
    end

    def repos filter
      repos = []
      query = proc { $github_api_client.organization_repositories(name, per_page: PER_PAGE) }
      r = Regexp.new(filter)

      request.get(query) do |raw_repos|
        raw_repos.each do |raw_repo|
          repos << Repo.new(raw_repo) if raw_repo[:name].match(r)
        end
      end

      repos
    end

    private

      attr_reader :name

      def request
        @request ||= Request.new
      end

  end
end
