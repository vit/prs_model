# coding: UTF-8

%w[].each {|r| require r}

$:.unshift __dir__
%w[].each {|r| require r}
$:.shift

module Coms
	class Post
		class TaskMgr
			POST_TASK_CLASS = 'COMS:POST:TASK'
			POST_TASK_ELM_CLASS = 'COMS:POST:TASK:ELM'
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
			def new_task attr={}
				id = @seq[]
				@coll.insert({ _id: id, _meta: {class: POST_TASK_CLASS, owner: nil, ctime: TS[], mtime: TS[]}, attr: attr })
				id
			end
			def new_task_elm task_id, attr={}, data={}
				id = @seq[]
				@coll.insert({ _id: id, _meta: {class: POST_TASK_ELM_CLASS, state: 'prepared', parent: task_id, owner: nil, ctime: TS[], mtime: TS[]}, attr: attr, data: data })
				id
			end

			def get_pkg_for_sending limit
				@coll.find({ '_meta.class' => POST_TASK_ELM_CLASS, '_meta.state' => 'sending'}).limit(limit).map do |e|
					e
				end
			end
			def set_task_elm_state elm_id, state, log
				@coll.update({ '_meta.class' => POST_TASK_ELM_CLASS, '_id' => elm_id}, {'$set' => {'_meta.state' => state, '_meta.log' => log}})
			end

			def get_prepared_elms limit
				@coll.find({ '_meta.class' => POST_TASK_ELM_CLASS, '_meta.state' => 'prepared'}).limit(limit).map do |e|
					e
				end
			end

			def get_task_elms task_id
				@coll.find({ '_meta.class' => POST_TASK_ELM_CLASS, '_meta.parent' => task_id}).map do |e|
					e
				end
			end
			def remove_task_elms task_id, elms=nil
				if elms.is_a? Array
					elms.each do |e|
						@coll.remove({ '_meta.class' => POST_TASK_ELM_CLASS, '_meta.parent' => task_id, '_id' => e})
					end
				else
					@coll.remove({ '_meta.class' => POST_TASK_ELM_CLASS, '_meta.parent' => task_id})
				end
			end
			def change_task_elms_state task_id, from, to, elms=nil
				if elms.is_a? Array
					if from
						elms.each do |e|
							@coll.update({ '_meta.class' => POST_TASK_ELM_CLASS, '_meta.parent' => task_id, '_meta.state' => from, '_id' => e}, {'$set' => {'_meta.state' => to}}, {multi: true})
						end
					else
						elms.each do |e|
							@coll.update({ '_meta.class' => POST_TASK_ELM_CLASS, '_meta.parent' => task_id, '_id' => e}, {'$set' => {'_meta.state' => to}}, {multi: true})
						end
					end
				else
					if from
						@coll.update({ '_meta.class' => POST_TASK_ELM_CLASS, '_meta.parent' => task_id, '_meta.state' => from}, {'$set' => {'_meta.state' => to}}, {multi: true})
					else
						@coll.update({ '_meta.class' => POST_TASK_ELM_CLASS, '_meta.parent' => task_id}, {'$set' => {'_meta.state' => to}}, {multi: true})
					end
				end
			end
			def remove_task task_id
				remove_task_elms task_id
				@coll.remove({ '_meta.class' => POST_TASK_CLASS, '_id' => task_id})
			end
			def get_tasks_list
				@coll.find( {'_meta.class' => POST_TASK_CLASS} ).sort( [[ '_meta.ctime', -1]] ).inject([]) do |acc,c|
					acc << {'_id' => c['_id'], '_meta' => c['_meta'], 'attr' => c['attr']}
				end
			end
			def get_task_info id
				c = @coll.find_one( {'_id' => id,'_meta.class' => POST_TASK_CLASS} )
				c.is_a?(Hash) ? {'_id' => c['_id'], '_meta' => c['_meta'], 'attr' => c['attr']} : nil
			end
			def supply_data data
				rez = {'_src' => data}
				if data['pin']
					#rez['user'] = @appl.user.get_user_info_ext( data['pin'] )
					rez['user'] = @appl.user.get_user_info_ext( data['pin'] )
				end
				rez
			end
			def gen_task_elms id
				t = get_task_info id
				lst1 = nil
				if t && t['attr']
				#	p 'exists'
					prod = t['attr']['producer']
					args = t['attr']['args']
					#prod ? @appl.post.producer.call(prod, args) : nil
					lst1 = prod ? @appl.post.producer.call(prod, args) : nil
					if lst1.is_a?(Array)
						lst1.each do |d|
							data = supply_data d
							new_task_elm id, t['attr'], data
							puts data
						end
					end
				end
			end
		end

	end
end


