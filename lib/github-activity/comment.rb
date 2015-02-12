module GithubActivity
  class Comment

    def initialize(raw)
      @raw = raw
    end

    def id
      @id ||= raw.id
    end

    def body
      @body ||= raw.body
    end

    private

      attr_reader :raw
  end
end
