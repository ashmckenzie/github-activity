module GithubActivity
  class Repo

    PER_PAGE = 100

    def initialize(raw)
      @raw = raw
    end

    def full_name
      @full_name ||= raw.full_name
    end

    def name
      @name ||= raw.name
    end

    def commits(date_from, date_to)
      query = proc { $github_api_client.commits_between(full_name, date_from, date_to, per_page: PER_PAGE) }
      request.get(query).map do |raw_commit|
        $moneta.fetch(raw_commit.sha) do |sha|
          GithubActivity::Commit.new(self, raw_commit).tap do |commit|
            $moneta[sha] = commit
          end
        end
      end
    end

    private

      attr_reader :raw

      def request
        @request ||= Request.new
      end
  end
end
