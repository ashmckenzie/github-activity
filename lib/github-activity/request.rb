module GithubActivity
  class Request

    def get query, sleep_duration=2
      data = []
      query.call
      last_response = $github_api_client.last_response

      loop do
        if block_given?
          yield(last_response.data)
        else
          data << last_response.data
        end

        break if last_response.data.empty? || !last_response.rels[:next]
        last_response = last_response.rels[:next].get
        sleep(sleep_duration)
        break if last_response.rels[:next].nil?
      end

      data.flatten
    end

  end
end
