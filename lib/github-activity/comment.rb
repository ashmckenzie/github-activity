module GithubActivity
  class Comment

    def initialize(raw)
      @raw = raw
    end

    def body
      @body ||= raw.body
    end

    private

      attr_reader :raw
  end
end
