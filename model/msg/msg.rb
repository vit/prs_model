# coding: UTF-8

$:.unshift ::File.expand_path(::File.dirname __FILE__)
#%w[mail].each {|r| require r}
$:.shift

module Coms
	class Msg
		MSG_MESSAGE_CLASS = 'COMS:MSG:MESSAGE'
		TS = -> { Time.now.utc.iso8601(10) }
		IdSeq = -> args=({}) {
			domain = (args[:domain] || 'localhost').to_s
			limit = (args[:size] || 40).to_i - 1
			-> { ( Digest::SHA1.new << domain+rand.to_s+TS[] ).to_s[0..limit] }
		}
		def initialize attr={}
			@seq = IdSeq[domain: 'localhost', size: 12]
			@appl = attr[:appl]
			@coll_name = attr[:coll_name]
			@coll = @appl.mongo.open_collection @coll_name
		end
		def get_my_object_thread pin, cont_id, paper_id
		#	@appl.conf.paper.get_paper_owner(cont_id, paper_id) == pin.to_i ? @coll.find({
		#		'_meta.class' => CONF_REVIEW_CLASS, '_meta.parent' => cont_id, '_meta.paper_id' => paper_id
		#	}).map do |r|
		#		{
		#			'data' => (r['data'] ? {'authcomments' => r['data']['authcomments']} : {})
		#		}
		#	end : []
			[]
		end

		def get_my_threads_on_paper pin, cont_id, paper_id
			pin = pin.to_i
			@coll.find(
				{'_meta.class' => MSG_MESSAGE_CLASS, '_meta.author' => pin, '_meta.context' => cont_id, '_meta.object.id' => paper_id}
			).sort( [[ '_meta.ctime', -1]] ).inject([]) do |acc,c|
				acc << {
					'_id' => c['_id'],
					'title' => c['data']['thread_title']
				}
			end
#				[
#					{title: 'post 001'},
#					{title: 'post 002'},
#					{title: 'post 003'},
#					{title: 'post 004'}
#				]
		end
		def add_my_message_on_paper pin, cont_id, paper_id, msg_text, thread_id, thread_title
			pin = pin.to_i
			ts = TS[]
			msg = {
				_id: @seq[],
				_meta: {class: MSG_MESSAGE_CLASS, thread_id: thread_id, author: pin, context: cont_id, object: {type: 'paper', id: paper_id}, ctime: ts, mtime: ts},
				data: {
					thread_title: thread_title,
					msg_text: msg_text
				}
			}
			unless thread_id
				msg[:_meta][:thread_id] = @seq[]
				msg[:_meta][:is_thread_head] = true
			end
			@coll.insert( msg )
		end

	end

end


