module GithubActivity
  class Repo

    PER_PAGE = 100

    def initialize raw
      @raw = raw
    end

    def full_name
      @full_name ||= raw.full_name
    end

    def name
      @name ||= raw.name
    end

    def commits date_from, date_to
      query = proc { $github_api_client.commits_between(full_name, date_from, date_to, per_page: PER_PAGE) }
      request.get(query).map { |raw_commit| GithubActivity::Commit.new(raw_commit) }
    end

    private

      attr_reader :raw

      def request
        @request ||= Request.new
      end
  end
end
