# coding: UTF-8

$:.unshift ::File.expand_path(::File.dirname __FILE__)
#%w[mail].each {|r| require r}
$:.shift

module Coms
	class Msg
		MSG_MESSAGE_CLASS = 'COMS:MSG:MESSAGE'
		MSG_MESSAGE_DRAFT_CLASS = 'COMS:MSG:MESSAGE:DRAFT'
		TS = -> { Time.now.utc.iso8601(10) }
		IdSeq = -> args=({}) {
			domain = (args[:domain] || 'localhost').to_s
			limit = (args[:size] || 40).to_i - 1
			-> { ( Digest::SHA1.new << domain+rand.to_s+TS[] ).to_s[0..limit] }
		}
		def initialize attr={}
		#	@seq = IdSeq[domain: 'localhost', size: 40]
			@seq = IdSeq[domain: 'localhost', size: 16]
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

		def create_my_message_draft_on_paper pin, cont_id, paper_id, thread_id
			pin = pin.to_i
			ts = TS[]
			id = @seq[]
			msg = {
				_id: id,
				_meta: {class: MSG_MESSAGE_DRAFT_CLASS, thread_id: thread_id, author: pin, context: cont_id, object: {type: 'paper', id: paper_id}, ctime: ts, mtime: ts},
				data: {
				#	thread_title: thread_title,
				#	msg_text: msg_text
					thread_title: '',
					msg_text: ''
				}
			}
			unless thread_id
			#	thread_id = @seq[]
				thread_id = id
				msg[:_meta][:thread_id] = thread_id
				msg[:_meta][:is_thread_head] = true
			end
			@coll.insert( msg )
			{_id: id, thread_id: thread_id}
		end
		def save_my_message_draft_data pin, _id, data
			#msg_text, thread_title
			pin = pin.to_i
			ts = TS[]
			@coll.update({'_meta.class' => MSG_MESSAGE_DRAFT_CLASS, '_id' => _id, '_meta.author' => pin}, {'$set' => {'data' => data, '_meta.mtime' => ts}})
		#	data
		end
		def get_my_message_draft_data pin, _id
			pin = pin.to_i
			res = @coll.find_one( {'_meta.class' => MSG_MESSAGE_DRAFT_CLASS, '_id' => _id, '_meta.author' => pin} )
			res && res['data'] ? res['data'] : {}
		end
		def get_my_message_data pin, _id
			pin = pin.to_i
			res = @coll.find_one( {'_meta.class' => MSG_MESSAGE_CLASS, '_id' => _id, '_meta.author' => pin} )
			res && res['data'] ? res['data'] : {}
		end
		def delete_my_message_draft pin, _id
			pin = pin.to_i
		#	res = @coll.find_one( {'_meta.class' => MSG_MESSAGE_DRAFT_CLASS, '_id' => _id, '_meta.author' => pin} )
			if @coll.find_one( {_id: _id, '_meta.class' => MSG_MESSAGE_DRAFT_CLASS, '_meta.author' => pin} )
			#	find_my_paper_files( pin, cont_id, _id).each{ |id| @grid.delete id }
			#	@coll.remove( {'_meta.class' => MSG_MESSAGE_DRAFT_CLASS, '_id' => _id, '_meta.author' => pin} )
				@coll.remove( {_id: _id, '_meta.class' => MSG_MESSAGE_DRAFT_CLASS, '_meta.author' => pin} )
			end
		end
		def save_my_draft_as_message pin, _id
			pin = pin.to_i
			ts = TS[]
			@coll.update(
				{'_meta.class' => MSG_MESSAGE_DRAFT_CLASS, '_id' => _id, '_meta.author' => pin},
				{'$set' => {'_meta.class' => MSG_MESSAGE_CLASS, '_meta.mtime' => ts, '_meta.ctime' => ts}}
			)
		end
		def get_my_threads_drafts_on_paper pin, cont_id, paper_id
			pin = pin.to_i
			@coll.find(
				{'_meta.class' => MSG_MESSAGE_DRAFT_CLASS, '_meta.author' => pin, '_meta.context' => cont_id, '_meta.object.id' => paper_id,
					'_meta.is_thread_head' => true
				#	'_meta.is_draft' => true
				}
			).sort( [[ '_meta.ctime', -1]] ).inject([]) do |acc,c|
				acc << {
					'_id' => c['_id'],
					'thread_title' => c['data']['thread_title'],
			#		'data' => c['data']
				}
			end
		end
		def get_my_threads_on_paper pin, cont_id, paper_id
			pin = pin.to_i
			@coll.find(
				{'_meta.class' => MSG_MESSAGE_CLASS, '_meta.author' => pin, '_meta.context' => cont_id, '_meta.object.id' => paper_id,
					'_meta.is_thread_head' => true
				#	'_meta.is_draft' => true
				}
			).sort( [[ '_meta.ctime', -1]] ).inject([]) do |acc,c|
				acc << {
					'_id' => c['_id'],
					'thread_id' => c['_meta']['thread_id'],
					'thread_title' => c['data']['thread_title'],
			#		'data' => c['data']
				}
			end
		end
		def get_my_messages_drafts_from_thread pin, thread_id
			pin = pin.to_i
			@coll.find(
				{'_meta.class' => MSG_MESSAGE_DRAFT_CLASS, '_meta.author' => pin, '_meta.thread_id' => thread_id,
				}
			).sort( [[ '_meta.ctime', -1]] ).inject([]) do |acc,c|
				acc << {
					'_id' => c['_id'],
			#		'thread_title' => c['data']['thread_title'],
					'data' => c['data']
				}
			end
		#	[thread_id]
		end
		def get_my_messages_from_thread pin, thread_id
			pin = pin.to_i
			@coll.find(
				{'_meta.class' => MSG_MESSAGE_CLASS, '_meta.author' => pin, '_meta.thread_id' => thread_id,
				#	'_meta.is_thread_head' => true
				}
		#	).sort( [[ '_meta.ctime', -1]] ).inject([]) do |acc,c|
			).sort( [[ '_meta.ctime']] ).inject([]) do |acc,c|
				acc << {
					'_id' => c['_id'],
			#		'thread_title' => c['data']['thread_title'],
					'data' => c['data']
				}
			end
		#	[thread_id]
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


