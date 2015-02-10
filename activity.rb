#!/usr/bin/env ruby

require 'bundler/setup'
require 'octokit'
require 'date'
require 'trollop'
require 'logger'
require 'dalli'
require 'moneta'

require_relative './lib/github-activity'

GITHUB_API_TOKEN = ENV['GITHUB_API_TOKEN'] || fail('GITHUB_API_TOKEN env var is missing')

opts = Trollop.options do
  opt :verbose, 'Verbose mode', default: false
  opt :debug, 'Debug mode', default: false
  opt :org, 'Organisation', type: :string, required: true
  opt :date_from, 'Date FROM (YYYY-MM-DD)', type: :string, required: true
  opt :date_to, 'Date TO (YYYY-MM-DD)', type: :string, required: true
  opt :filter, 'Filter repositories regex', type: :string
end

Trollop.die('Date FROM must be *BEFORE* Date TO') if DateTime.parse(opts[:date_from]) > DateTime.parse(opts[:date_to])

DATE_FROM       = opts[:date_from]
DATE_TO         = opts[:date_to]
ORGANISATION    = opts[:org]
FILTER          = opts[:filter]

VERBOSE         = opts[:verbose]
DEBUG        = opts[:debug]

require 'pry-byebug' if DEBUG

CSV_OUTPUT_FILE = "output_#{ORGANISATION}_#{DATE_FROM.downcase}-#{DATE_TO.downcase}.csv"

$logger = Logger.new(STDOUT).tap { |logger| logger.level = Logger::DEBUG }
$moneta = Moneta.new(:Memory)
$github_api_client = Octokit::Client.new(access_token: GITHUB_API_TOKEN).tap { |client| client.user.login }

if VERBOSE
  puts '========================================='
  puts "Commits between #{DATE_FROM} and #{DATE_TO}"
  puts "=========================================\n\n"
end

org = GithubActivity::Organisation.new(ORGANISATION)
formatters = [ GithubActivity::Formatters::CSV.new(CSV_OUTPUT_FILE) ]

org.repos(filter: FILTER).each do |repo|
  repo.commits(DATE_FROM, DATE_TO).each do |commit|
    formatters.each do |formatter|
      formatter.render(repo: repo, commit: commit)
      print('+') if VERBOSE
    end
  end

  print('.') if VERBOSE
end

puts if VERBOSE

formatters.each(&:finish!)

$moneta.close
