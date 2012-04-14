
module Coms
	module Conf
		class Review
			CONF_REVIEW_CLASS = 'COMS:CONF:REVIEW'
			CONF_REVIEW2_CLASS = 'COMS:CONF:REVIEW2'
			#attr_accessor :appl
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
				#@coll = @appl.mongo.open_collection "conf"
			end
			#def get_reviewer_scores cont_id, lang_code
			def get_reviewer_scores cont_id
				[:a, :b, :c, :d]
			end

			def save_my_review_data pin, cont_id, paper_id, data
				_id = @seq[]
				ts = TS[]
				@coll.db.eval "function() {
					var query = {'_meta.class': '#{CONF_REVIEW_CLASS}', '_meta.owner': #{pin.to_i}, '_meta.parent': '#{cont_id}', '_meta.paper_id': '#{paper_id}'};
					var newobj = {'_id': '#{_id}', '_meta': {'class': '#{CONF_REVIEW_CLASS}', 'owner': #{pin.to_i}, 'parent': '#{cont_id}', 'paper_id': '#{paper_id}', 'ctime': '#{ts}', 'mtime': '#{ts}'}, data: {}};
					if( !db.#{@coll_name}.findOne(query) )
						db.#{@coll_name}.insert(newobj);
				}"
				@coll.update(
					{'_meta.class' => CONF_REVIEW_CLASS, '_meta.owner' => pin.to_i, '_meta.parent' => cont_id, '_meta.paper_id' => paper_id},
					{'$set' => {'data' => data, '_meta.mtime' => ts} }
				)
				data
			end
			def get_my_review_data pin, cont_id, paper_id
				res = @coll.find_one({
					'_meta.class' => CONF_REVIEW_CLASS, '_meta.owner' => pin.to_i, '_meta.parent' => cont_id, '_meta.paper_id' => paper_id
				})
				res ? res['data'] : nil
			end

			def save_my_review2_data pin, cont_id, paper_id, data
				_id = @seq[]
				ts = TS[]
				@coll.db.eval "function() {
					var query = {'_meta.class': '#{CONF_REVIEW2_CLASS}', '_meta.owner': #{pin.to_i}, '_meta.parent': '#{cont_id}', '_meta.paper_id': '#{paper_id}'};
					var newobj = {'_id': '#{_id}', '_meta': {'class': '#{CONF_REVIEW2_CLASS}', 'owner': #{pin.to_i}, 'parent': '#{cont_id}', 'paper_id': '#{paper_id}', 'ctime': '#{ts}', 'mtime': '#{ts}'}, data: {}};
					if( !db.#{@coll_name}.findOne(query) )
						db.#{@coll_name}.insert(newobj);
				}"
				@coll.update(
					{'_meta.class' => CONF_REVIEW2_CLASS, '_meta.owner' => pin.to_i, '_meta.parent' => cont_id, '_meta.paper_id' => paper_id},
					{'$set' => {'data' => data, '_meta.mtime' => ts} }
				)
				data
			end
			def get_my_review2_data pin, cont_id, paper_id
				res = @coll.find_one({
					'_meta.class' => CONF_REVIEW2_CLASS, '_meta.owner' => pin.to_i, '_meta.parent' => cont_id, '_meta.paper_id' => paper_id
				})
				res ? res['data'] : nil
			end

			def get_my_paper_reviews pin, cont_id, paper_id
				@appl.conf.paper.get_paper_owner(cont_id, paper_id) == pin.to_i ? @coll.find({
					'_meta.class' => CONF_REVIEW_CLASS, '_meta.parent' => cont_id, '_meta.paper_id' => paper_id
			#	}).inject([]) do |acc, r|
			#		acc << {
			#			'data' => (r['data'] ? {'authcomments' => r['data']['authcomments']} : {})
			#		}
				}).map do |r|
					{
						'data' => (r['data'] ? {'authcomments' => r['data']['authcomments']} : {})
					}
				end : []
			end
			def get_my_paper_reviews2 pin, cont_id, paper_id
				@appl.conf.paper.get_paper_owner(cont_id, paper_id) == pin.to_i ? @coll.find({
					'_meta.class' => CONF_REVIEW2_CLASS, '_meta.parent' => cont_id, '_meta.paper_id' => paper_id
				}).map do |r|
					{
						'data' => (r['data'] ? {'authcomments' => r['data']['authcomments']} : {})
					}
				end : []
			end
			def get_paper_reviews cont_id, paper_id
				@coll.find({
					'_meta.class' => CONF_REVIEW_CLASS, '_meta.parent' => cont_id, '_meta.paper_id' => paper_id
				}).inject([]) do |acc, r|
					acc << {
						'_meta' => r['_meta'],
						'data' => r['data']
					}
				end
			end
			def get_paper_reviews_ext cont_id, paper_id
				get_paper_reviews(cont_id, paper_id).map do |r|
					u = @appl.user.get_user_info r['_meta']['owner']
					r['reviewer'] = u
				#	{
				#		'user_name' => sprintf('%s %s %s', u['fname'][lang_code], u['mname'][lang_code], u['lname'][lang_code]),
				#	}
					r
				end
			end
			def delete_review cont_id, paper_id, owner
				@coll.remove('_meta.class' => CONF_REVIEW_CLASS, '_meta.owner' => owner.to_i, '_meta.parent' => cont_id, '_meta.paper_id' => paper_id);
			end
		end
	end
end

