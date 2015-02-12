#!/usr/bin/env ruby

require 'bundler/setup'
require 'octokit'
require 'date'
require 'trollop'
require 'logger'
require 'naught'

require 'dalli'
require 'moneta'

require_relative './lib/github-activity'

GITHUB_API_TOKEN = ENV['GITHUB_API_TOKEN'] || fail('GITHUB_API_TOKEN env var is missing')

opts = Trollop.options do
  opt :verbose, 'Verbose mode', default: false
  opt :debug, 'Debug mode', default: false
  opt :extreme_debug, 'EXTREME debug mode', default: false

  opt :org, 'Organisation', type: :string, required: true
  opt :date_from, 'Date FROM (YYYY-MM-DD)', type: :string, required: true
  opt :date_to, 'Date TO (YYYY-MM-DD)', type: :string, required: true

  opt :filter, 'Filter repositories regex', type: :string
  opt :repos, 'Comma separated list of repos to search', type: :string
end

Trollop.die('Date FROM must be *BEFORE* Date TO') if DateTime.parse(opts[:date_from]) > DateTime.parse(opts[:date_to])
Trollop.die('--filter and --repos are mutually exclusive') if opts[:filter] && opts[:repos]

DATE_FROM         = opts[:date_from]
DATE_TO           = opts[:date_to]
ORGANISATION_NAME = opts[:org]

if opts[:filter]
  REPO_LOOKUP_KLASS  = GithubActivity::RepoLookup::Regex
  REPO_LOOKUP_FILTER = opts[:filter]
else
  REPO_LOOKUP_KLASS  = GithubActivity::RepoLookup::Exact
  REPO_LOOKUP_FILTER = opts.fetch(:repos, []).split(',').map(&:strip)
end

VERBOSE       = opts[:verbose]
DEBUG         = opts[:debug]
EXTREME_DEBUG = opts[:extreme_debug]

if DEBUG || EXTREME_DEBUG
  require 'pry-byebug'

  if EXTREME_DEBUG
    stack = Faraday::RackBuilder.new do |builder|
      builder.response :logger
      builder.use Octokit::Response::RaiseError
      builder.adapter Faraday.default_adapter
    end

    Octokit.middleware = stack
  end
end

CSV_OUTPUT_FILE = "output_#{ORGANISATION_NAME}_#{DATE_FROM.downcase}-#{DATE_TO.downcase}.csv"

$logger = Logger.new(STDOUT).tap { |logger| logger.level = Logger::DEBUG }
$github_api_client = Octokit::Client.new(access_token: GITHUB_API_TOKEN).tap { |client| client.user.login }

$moneta = Moneta.new(:Memory)
# $moneta = Moneta.new(:MemcachedDalli)

org = GithubActivity::Organisation.new(ORGANISATION_NAME)
formatters = [ GithubActivity::Formatters::CSV.new(CSV_OUTPUT_FILE) ]

org.repos(REPO_LOOKUP_KLASS, REPO_LOOKUP_FILTER).each do |repo|
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
