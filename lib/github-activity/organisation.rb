module GithubActivity
  class Organisation

    def initialize(name)
      @name = name
    end

    def repos(klass, filter)
      @repos ||= klass.new(name, filter).lookup
    end

    private

      attr_reader :name

  end
end
