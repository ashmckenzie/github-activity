module GithubActivity
  class Request

    def get query, sleep_duration: nil
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

        sleep(sleep_duration) if sleep_duration
      end

      data.flatten
    end

  end
end
