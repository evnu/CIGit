#!/usr/bin/ruby
#
# Small Sinatra application to display the results of the test runs
#

require 'sinatra'

def build_log
    "/tmp/.build_log"
end

get '/' do
    # get the revs from the build log
    revs = []

    File.open(build_log) do |f|
        f.each do |line|
            revs << line.split
        end
    end
    erb :index, locals: { commits: revs }
end
