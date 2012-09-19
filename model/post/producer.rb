# coding: UTF-8

%w[].each {|r| require r}

$:.unshift ::File.expand_path(::File.dirname __FILE__)
%w[].each {|r| require r}
$:.shift

module Coms
	class Post
		class Producer
			class Config
				attr_reader :query
				def initialize
				#	@main = 'qqqqq'
				end
				def test
					yield
				end
				def main &block
					@query = block
				#	@main = 'wwwww'
				end
			end
			class Scope
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

#				@items = {}
#
#				Dir.glob( File.join( File.expand_path(::File.dirname __FILE__), 'db/*.rb' ) ) do |fname|
#					name = File.basename(fname, ".rb")
##				#	puts name
#				#	puts fname
#			#		str = File.read fname, "r:UTF-8"
#					File.open(fname, "r:UTF-8") do |f|
#						str = f.read
#						config = Config.new
#						config.instance_exec do
#							eval str, binding
#						end
#						@items[name] = config
#					end
#
#				#	puts str
#				end

			end
			def call name, args={}
			#	puts File.join( File.expand_path(::File.dirname __FILE__), 'db')
		#		File.join( File.expand_path(::File.dirname __FILE__), 'db', name+'.rb').to_s
			#	'asdsdfgsdgdfh'
				File.open( File.join( File.expand_path(::File.dirname __FILE__), 'db', name+'.rb' ), "r:UTF-8") do |f|
					str = f.read
					config = Config.new
					config.instance_exec do
						eval str, binding
					end
		#			config.call args
					scope = Scope.new
				#	scope.instance_exec args, &config.main if config.main
				#	return config.main.to_s
					return config.query[args].to_s if config.query
				#	config.to_s
				end
			#	'asdsdfgsdgdfh'
			end
		end

	end
end


