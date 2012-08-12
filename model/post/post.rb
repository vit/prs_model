# coding: UTF-8

$:.unshift ::File.expand_path(::File.dirname __FILE__)
%w[].each {|r| require r}
$:.shift

module Coms
	class Post
	#	MSG_MESSAGE_CLASS = 'COMS:MSG:MESSAGE'
	#	MSG_MESSAGE_DRAFT_CLASS = 'COMS:MSG:MESSAGE:DRAFT'
		TS = -> { Time.now.utc.iso8601(10) }
		IdSeq = -> args=({}) {
			domain = (args[:domain] || 'localhost').to_s
			limit = (args[:size] || 40).to_i - 1
			-> { ( Digest::SHA1.new << domain+rand.to_s+TS[] ).to_s[0..limit] }
		}
		def initialize attr={}
			@attr = attr
			@seq = IdSeq[domain: 'localhost', size: 16]
			@appl = attr[:appl]
			@coll_name = attr[:coll_name]
			@coll = @appl.mongo.open_collection @coll_name
		end

	end
end




