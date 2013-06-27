# coding: UTF-8

%w[].each {|r| require r}

$:.unshift __dir__
%w[].each {|r| require r}
$:.shift

module Coms
	class Post
		class TaskMgr
		#	POST_TEMPLATE_CLASS = 'COMS:POST:TEMPLATE'
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
end


