#!/usr/bin/env ruby

require 'bundler/setup'
require 'octokit'
require 'date'
require 'trollop'

require_relative './lib/github-activity'

GITHUB_API_TOKEN = ENV['GITHUB_API_TOKEN'] || raise('GITHUB_API_TOKEN env var is missing')

opts = Trollop::options do
  opt :org, "Organisation", type: :string, required: true
  opt :date_from, "Date FROM (YYYY-MM-DD)", type: :string, required: true
  opt :date_to, "Date TO (YYYY-MM-DD)", type: :string, required: true
  opt :filter, "Filter repositories regex", type: :string
end

Trollop::die "Date FROM must be *BEFORE* Date TO" if DateTime.parse(opts[:date_from]) > DateTime.parse(opts[:date_to])

DATE_FROM       = opts[:date_from]
DATE_TO         = opts[:date_to]
ORGANISATION    = opts[:org]
FILTER          = opts[:filter]

CSV_OUTPUT_FILE = "output_#{ORGANISATION}_#{DATE_FROM.downcase}-#{DATE_TO.downcase}.csv"

puts "========================================="
puts "Commits between #{DATE_FROM} and #{DATE_TO}"
puts "=========================================\n\n"

$github_api_client = Octokit::Client.new(access_token: GITHUB_API_TOKEN)
$github_api_client.user.login

org = GithubActivity::Organisation.new(ORGANISATION)
csv = GithubActivity::Formatters::CSV.new(CSV_OUTPUT_FILE)
human = GithubActivity::Formatters::Human.new

org.repos(FILTER).each do |repo|
  commits = repo.commits(DATE_FROM, DATE_TO)

  puts "===> #{repo.full_name} "
  puts "#{commits.count} commits\n"

  unless commits.empty?
    commits.each do |commit|
      human.render(commit)
      csv.render(repo.name, commit)
    end
    human.print_line
  end

  puts
end

csv.finish!
