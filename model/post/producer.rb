# coding: UTF-8

%w[].each {|r| require r}

$:.unshift ::File.expand_path(::File.dirname __FILE__)
%w[].each {|r| require r}
$:.shift

module Coms
	class Post
		class Producer
			class Config
				def test
					yield
				end
			end
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

				@items = {}

				Dir.glob( File.join( File.expand_path(::File.dirname __FILE__), 'db/*.rb' ) ) do |fname|
					name = File.basename(fname, ".rb")
				#	puts name
				#	puts fname
			#		str = File.read fname, "r:UTF-8"
					File.open(fname, "r:UTF-8") do |f|
						str = f.read
						config = Config.new
						config.instance_exec do
							eval str, binding
						end
						@items[name] = config
					end

				#	puts str
				end

			end
		end

	end
end


