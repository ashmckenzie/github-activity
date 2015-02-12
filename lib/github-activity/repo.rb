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
      Commit.find_between(self, date_from, date_to)
    end

    def cache_key
      'repo:%s' % full_name
    end

    private

      attr_reader :raw

      def request
        @request ||= Request.new
      end

  end
end
