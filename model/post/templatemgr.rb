# coding: UTF-8

%w[].each {|r| require r}

$:.unshift __dir__
%w[].each {|r| require r}
$:.shift

module Coms
	class Post
		class TemplateMgr
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
			def get_file name
				File.open( File.join( File.expand_path( __dir__ ), 'templates', name+'.rb' ), "r:UTF-8") do |f|
					str = f.read
				#	config = Config.new
				#	config.instance_exec do
				#		eval str, binding
				#	end
				#	scope = Scope.new @appl
				#	return scope.instance_exec args, &config.query if config.query
				end
			end
			def get_files_list
				result = []
				Dir.glob( File.join( File.expand_path( __dir__ ), 'templates/*.rb' ) ) do |fname|
					name = File.basename(fname, ".rb")
					result << name
				end
				result.sort
			end
			def exists? name
				Dir.glob( File.join( File.expand_path( __dir ), 'templates/*.rb' ) ) do |fname|
					name = File.basename(fname, ".rb")
					return File.file?(fname)
				end
			end

			def parse_src str
				parser = Parser.new
				parser.instance_exec do
					eval str, binding
				end
				parser
			#	scope = Scope.new @appl
			#	return scope.instance_exec args, &config.query if config.query
			end
			def apply text, data={}
				c = Context.new data
				ERB.new(text).result(c.instance_eval { binding })
			end
			class Parser
				attr_reader :parsed
				def initialize
					@parsed = {}
				end
				def subject s
					@parsed['subject'] = s
				end
				def body s
					@parsed['body'] = s
				end
			end
			class Context
				def initialize data
					@data = data
					data.each_pair do |key, value|
						instance_variable_set('@' + key.to_s, value)
					end
				end
			end
		end

	end
end


