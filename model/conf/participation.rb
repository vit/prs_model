
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
			end

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
			def save_my_participation_data pin, cont_id, _id, data
				pin = pin.to_i
				ts = TS[]
					@coll.update(
						{'_meta.class' => CONF_PARTICIPATION_FORM_CLASS, _id: _id, '_meta.owner' => pin, '_meta.parent' => cont_id},
						{'$set' => {data: data, '_meta.mtime' => ts} }
					)
				_id
			end
			def get_my_participation_data pin, cont_id, _id
				pin = pin.to_i
				res = @coll.find_one( {_id: _id, '_meta.class' => CONF_PARTICIPATION_FORM_CLASS, '_meta.owner' => pin, '_meta.parent' => cont_id} )
				res && res['data'] ? res['data'] : nil
			end
			def drop_my_participation pin, cont_id, _id
				pin = pin.to_i
				@coll.remove( {_id: _id, '_meta.class' => CONF_PARTICIPATION_FORM_CLASS, '_meta.owner' => pin, '_meta.parent' => cont_id} )
			end
		end
	end
end


