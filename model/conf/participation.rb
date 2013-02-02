
#%w[mongo time digest/sha1].each {|r| require r}

module Coms
	module Conf
		class Participation
			CONF_PARTICIPATION_FORM_CLASS = 'COMS:CONF:PARTICIPATION:FORM'
			attr_reader :coll
			TS = -> { Time.now.utc.iso8601(10) }
			IdSeq = -> args=({}) {
				domain = (args[:domain] || 'localhost').to_s
				limit = (args[:size] || 40).to_i - 1
				-> { ( Digest::SHA1.new << domain+rand.to_s+TS[] ).to_s[0..limit] }
			}
			def initialize attr={}
				@seq = IdSeq[domain: 'localhost', size: 16]
				@appl = attr[:appl]
				@coll_name = attr[:coll_name]
				@coll = @appl.mongo.open_collection @coll_name
			end

=begin
			def create_my_participation pin, cont_id, _id
				pin = pin.to_i
				ts = TS[]
				data = {}
					_id = @seq[]
					@coll.insert({
						_id: _id,
						_meta: {class: CONF_PARTICIPATION_FORM_CLASS, owner: pin, parent: cont_id, ctime: ts, mtime: ts},
						data: data
					})
				_id
			end
=end
			def create_my_participation pin, cont_id
#				'qweqwqw rt eryet yru tyu'
				save_my_participation_data(pin, cont_id, {})
			end
			def save_my_participation_data pin, cont_id, data={}
				pin = pin.to_i
			#	_id = @seq[]
				ts = TS[]
				@coll.db.eval "function() {
					var query = {'_meta.class': '#{CONF_PARTICIPATION_FORM_CLASS}', '_meta.owner': #{pin.to_i}, '_meta.parent': '#{cont_id}'};
					var newobj = {'_meta': {'class': '#{CONF_PARTICIPATION_FORM_CLASS}', 'owner': #{pin.to_i}, 'parent': '#{cont_id}', 'ctime': '#{ts}', 'mtime': '#{ts}'}, data: {}};
					if( !db.#{@coll_name}.findOne(query) )
						db.#{@coll_name}.insert(newobj);
				}"
				@coll.update(
					{'_meta.class' => CONF_PARTICIPATION_FORM_CLASS, '_meta.owner' => pin.to_i, '_meta.parent' => cont_id},
					{'$set' => {'data' => data, '_meta.mtime' => ts} }
				)
			#	_id
			#	123
		#		data
			end
			def get_my_participation_data pin, cont_id
				pin = pin.to_i
				res = @coll.find_one( {'_meta.class' => CONF_PARTICIPATION_FORM_CLASS, '_meta.owner' => pin, '_meta.parent' => cont_id} )
				res && res['data'] ? res['data'] : nil
			#	{q: 'w'}
			end
			def drop_my_participation pin, cont_id
				pin = pin.to_i
				@coll.remove( {'_meta.class' => CONF_PARTICIPATION_FORM_CLASS, '_meta.owner' => pin, '_meta.parent' => cont_id} )
			end
			def _submitted_all cont_id
				@coll.find(
					{'_meta.class' => CONF_PARTICIPATION_FORM_CLASS, '_meta.parent' => cont_id}
				)
			end
		end
	end
end


