# coding: UTF-8

%w[mongo time digest/sha1 unicode_utils].each {|r| require r}

$:.unshift ::File.expand_path(::File.dirname __FILE__)
%w[paper review report participation].each {|r| require r}
$:.shift

module Coms
	module Conf
		class Model
			CONF_CLASS = 'COMS:CONF'
		#	attr_accessor :appl, :conn, :coll_name, :report, :review, :paper
			attr_accessor :appl, :coll_name, :report, :review, :paper, :participation
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
				@paper = Paper.new({appl: @appl, coll_name: @coll_name+'.paper'})
				@review = Review.new({appl: @appl, coll_name: @coll_name+'.review'})
				@report = Report.new({appl: @appl})
				@participation = Participation.new({appl: @appl, coll_name: @coll_name+'.participation'})
			end
			def clear
				@coll.clear
			end

			def get_meta _id
				@coll.find_one( {_id: _id}, {_meta: 1} )
			end
			def new attr={}
				{ _id: @coll.insert({_id: @seq[], _meta: {class: CONF_CLASS, owner: nil, paper_cnt: 1, ctime: TS[], mtime: TS[]}, info: { title: '', description: ''} }) }
			end
			def get_conf_data _id
				@coll.find_one( {'_meta.class' => CONF_CLASS, _id: _id} )
			end
			def next_paper_cnt _id
				res = @coll.find_and_modify({query: {'_meta.class' => CONF_CLASS, _id: _id}, update: {'$inc' => {'_meta.paper_cnt' => 1} } })
				res && res['_meta'] && res['_meta']['paper_cnt'] ? res['_meta']['paper_cnt'].to_i : nil
			end
			def get_conf_info _id
				res = get_conf_data _id
				res.is_a?(Hash) ? res['info'] : nil
			end
			def save_conf_info _id, info
				@coll.update( {'_meta.class' => CONF_CLASS, _id: _id}, {'$set' => {info: info, '_meta.mtime' => TS[]} } )
			end
			def get_conf_downloads _id
				res = get_conf_data _id
				res.is_a?(Hash) ? res['downloads'] : nil
			end
			def save_conf_downloads _id, downloads
				@coll.update( {'_meta.class' => CONF_CLASS, _id: _id}, {'$set' => {downloads: downloads, '_meta.mtime' => TS[]} } )
			end
			def get_conf_keywords _id
				res = get_conf_data _id
				res.is_a?(Hash) ? res['keywords'] : nil
			end
			def save_conf_keywords _id, keywords
				@coll.update( {'_meta.class' => CONF_CLASS, _id: _id}, {'$set' => {keywords: keywords, '_meta.mtime' => TS[]} } )
			end
			def get_confs_list
				@coll.find( {'_meta.class' => CONF_CLASS} ).sort( [[ '_meta.ctime', -1]] ).inject([]) do |acc,c|
					acc << {'_id' => c['_id'], '_meta' => c['_meta'], 'info' => c['info']}
				end
			end

			def new_conf_role _id, name
				name.strip!
				if name.length > 0
					rid = @seq[]
					elm = { id: rid, name: name, rights: {}, members: [] }
					@coll.update( {'_meta.class' => CONF_CLASS, _id: _id}, {'$push' => {roles: elm} } )
					rid
				end
			end

			def get_users_by_right _id, right
				roles = @coll.find_one( {'_meta.class' => CONF_CLASS, _id: _id}, fields: {roles: 1} )['roles'] || []
				roles.select do |r|
					r['rights'] && r['rights'][right]
				end.map do |r|
					r['members'] || []
				end.flatten
			end

			def get_conf_role_rights _id, rid
				res = @coll.find_one( {'_meta.class' => CONF_CLASS, _id: _id}, fields: {roles: 1} )['roles'].select { |r| r['id']==rid }.first
				res ? res['rights'] : nil
			end
			def set_conf_role_rights _id, rid, rights={}
				@coll.update( {'_meta.class' => CONF_CLASS, _id: _id, 'roles.id' => rid}, {'$set' => {'roles.$.rights' => rights} } )
			end
			def add_conf_role_member _id, rid, pin
				@coll.update({'_meta.class' => CONF_CLASS, _id: _id, 'roles.id' => rid}, {'$addToSet' => {'roles.$.members' => pin.to_i} })
			end
			def remove_conf_role_member _id, rid, pin
				@coll.update({'_meta.class' => CONF_CLASS, _id: _id, 'roles.id' => rid}, {'$pull' => {'roles.$.members' => pin.to_i} })
			end
			def get_conf_role_members _id, rid
				res = @coll.find_one( {'_meta.class' => CONF_CLASS, _id: _id}, fields: {roles: 1} )['roles'].select { |r| r['id']==rid }.first
				res ? res['members'] : nil
			end
			def delete_conf_role _id, rid
				@coll.update( {'_meta.class' => CONF_CLASS, _id: _id, 'roles.id' => rid}, {'$unset' => {'roles.$' => 1} } )
				@coll.update( {'_meta.class' => CONF_CLASS, _id: _id}, {'$pull' => {'roles' => nil} } )
			end
			def get_conf_roles _id
				res = get_conf_data _id
				res.is_a?(Hash) ? res['roles'] : nil
			end
			def get_user_rights _id, pin
				#res = @coll.find_one( {'_meta.class' => CONF_CLASS, _id: _id} )['roles']
				res = @coll.find_one( {'_meta.class' => CONF_CLASS, _id: _id} )
				permissions = res && res['permissions'] ? res['permissions'] : {}
				roles = res && res['roles'] ? res['roles'] : {}
				#res ? res.inject({}) do |acc, r|
				roles.inject(permissions) do |acc, r|
					if r['rights'].is_a?( Hash ) and r['members'].is_a?( Array ) and r['members'].include?( pin.to_i )
						r['rights'].each_pair do |k, v|
							acc[k] ||= true if v
						end
					end
					acc
				end
			end
			def get_my_rights pin, _id
				get_user_rights _id, pin
			end

			def new_conf_section _id, name
				#name.strip! if name.is_a? String
				#if name.length > 0
					sid = @seq[]
					elm = { id: sid, name: name, managers: [] }
					@coll.update( {'_meta.class' => CONF_CLASS, _id: _id}, {'$push' => {sections: elm} } )
				#	p sid
					sid
				#end
			end
			def set_conf_section_name _id, sid, name
				@coll.update({'_meta.class' => CONF_CLASS, _id: _id, 'sections.id' => sid}, {'$set' => {'sections.$.name' => name} })
			end
			def add_conf_section_manager _id, sid, pin
				@coll.update({'_meta.class' => CONF_CLASS, _id: _id, 'sections.id' => sid}, {'$addToSet' => {'sections.$.managers' => pin.to_i} })
			end
			def remove_conf_section_manager _id, sid, pin
				@coll.update({'_meta.class' => CONF_CLASS, _id: _id, 'sections.id' => sid}, {'$pull' => {'sections.$.managers' => pin.to_i} })
			end
			def get_conf_section_managers _id, sid
				res = @coll.find_one( {'_meta.class' => CONF_CLASS, _id: _id}, fields: {sections: 1} )['sections'].select { |r| r['id']==sid }.first
				p res
				res ? res['managers'] : nil
			end
			def delete_conf_section _id, sid
				@coll.update( {'_meta.class' => CONF_CLASS, _id: _id, 'sections.id' => sid}, {'$unset' => {'sections.$' => 1} } )
				@coll.update( {'_meta.class' => CONF_CLASS, _id: _id}, {'$pull' => {'sections' => nil} } )
			end
			def get_conf_sections _id
				res = get_conf_data _id
			#	p res.is_a?(Hash) ? res['sections'] : nil
			#	res.is_a?(Hash) ? res['sections'] : nil
				res.is_a?(Hash) && res['sections'] ? res['sections'] : []
			end
			def get_user_sections _id, pin
				res = @coll.find_one( {'_meta.class' => CONF_CLASS, _id: _id} )['sections']
				res ? res.select do |s|
					s['managers'].is_a?( Array ) and s['managers'].include?( pin.to_i )
				end.map do |s|
					s['id']
				end : []
			end

			def get_all_decisions cont_id
				[:reject, :accept, :accept_plenary, :accept_poster]
			end
			def get_reviewer_decisions _id
				res = get_conf_data _id
				res.is_a?(Hash) && res['decisions'] ? res['decisions'] : get_all_decisions(_id)
			end
			def set_reviewer_decisions _id, data
				@coll.update( {'_meta.class' => CONF_CLASS, _id: _id}, {'$set' => {decisions: data, '_meta.mtime' => TS[]} } )
				data
			end

			def get_permissions_list cont_id
				[
					:USER_REGISTER_NEW_PAPER,
					:PAPREG_PAPER_EDIT,
					:PAPREG_PAPER_DELETE,
					:PAPREG_PAPER_ABSTRACT_UPLOAD,
					:PAPREG_PAPER_ABSTRACT_REUPLOAD,
					:PAPREG_PAPER_ABSTRACT_REMOVE,
					:PAPREG_PAPER_FILE_UPLOAD,
					:PAPREG_PAPER_FILE_REUPLOAD,
					:PAPREG_PAPER_FILE_REMOVE,
					:PAPREG_PAPER_PRESENTATION_UPLOAD,
					:PAPREG_PAPER_PRESENTATION_REUPLOAD,
					:PAPREG_PAPER_PRESENTATION_REMOVE,
				#	:PAPREG_PAPER_EXDOC_UPLOAD,
				#	:PAPREG_PAPER_EXDOC_REUPLOAD,
				#	:PAPREG_PAPER_EXDOC_REMOVE,
					:PAPREG_VIEW_FINAL_DECISION,
					:PAPREG_VIEW_REVIEWERS_COMMENTS,
					:PAPREG_VIEW_SECTMANS_COMMENTS,
					:PARTICIPANT_EDIT_REGFORM,
					:PARTICIPANT_GIVE_UP_PARTICIPATION,
					:REVIEWER_EDIT_REVIEWS,
					:REVIEWER_VIEW_REVIEWING_DATA,
					:SECTMAN_WRITE_COMMENTS,
					:SYS_ADMIN_IS_ORDINARY,
					:SYS_ALLOW_PRESENTATION_FILE,
					:USER_REGISTER_PARTICIPATION
				]
			end
			def get_conf_permissions _id
				res = get_conf_data _id
			#	res.is_a?(Hash) ? res['permissions'] : nil
			#	res = @coll.find_one( {'_meta.class' => CONF_CLASS, _id: _id} )
				res ? res['permissions'] : nil
			#	{ :PAPREG_PAPER_FILE_UPLOAD => true }
			end
			def set_conf_permissions _id, permissions={}
				@coll.update( {'_meta.class' => CONF_CLASS, _id: _id}, {'$set' => {'permissions' => permissions} } )
			end

			def user_is_section_manager pin, _id
				pin and @coll.find_one(
					{'_meta.class' => CONF_CLASS, _id: _id, 'sections.managers' => pin.to_i}
				) ? true : false
			end
			def user_is_conf_owner pin, _id=nil
				pin and @coll.find_one(
					_id ?
					{'_meta.class' => CONF_CLASS, '_meta.owner' => pin, _id: _id} :
					{'_meta.class' => CONF_CLASS, '_meta.owner' => pin}
				) ? true : false
			end
		end
	end
end


