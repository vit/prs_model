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

		def get_templates cont_id
		#	pin = pin.to_i
	#		@coll.find(
	#			{'_meta.class' => MSG_MESSAGE_CLASS, '_meta.author' => pin, '_meta.context' => cont_id, '_meta.object.id' => paper_id,
	#				'_meta.is_thread_head' => true
	#			#	'_meta.is_draft' => true
	#			}
	#		).sort( [[ '_meta.ctime', -1]] ).inject([]) do |acc,c|
	#			acc << {
	#				'_id' => c['_id'],
	#				'thread_id' => c['_meta']['thread_id'],
	#				'thread_title' => c['data']['thread_title'],
	#		#		'data' => c['data']
	#			}
	#		end
			[
				{_id: 1, title: {en: 'title 01', ru: 'название 01'}},
				{_id: 2, title: {en: 'title 02', ru: 'название 02'}},
				{_id: 3, title: {en: 'title 03', ru: 'название 03'}},
			]
		end
		def get_template_data cont_id, template_id
		#	pin = pin.to_i
	#		@coll.find(
	#			{'_meta.class' => MSG_MESSAGE_CLASS, '_meta.author' => pin, '_meta.context' => cont_id, '_meta.object.id' => paper_id,
	#				'_meta.is_thread_head' => true
	#			#	'_meta.is_draft' => true
	#			}
	#		).sort( [[ '_meta.ctime', -1]] ).inject([]) do |acc,c|
	#			acc << {
	#				'_id' => c['_id'],
	#				'thread_id' => c['_meta']['thread_id'],
	#				'thread_title' => c['data']['thread_title'],
	#		#		'data' => c['data']
	#			}
	#		end
			{_id: 2, title: {en: 'title 01', ru: 'название 01'}}
		end

	end
end




