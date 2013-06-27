
#%w[mongo time digest/sha1].each {|r| require r}

module Coms
	module Conf
		class Paper
			CONF_PAPER_CLASS = 'COMS:CONF:PAPER'
			CONF_PAPER_ABSTRACT_FILE_CLASS = 'COMS:CONF:PAPER:ABSTRACT:FILE'
			CONF_PAPER_ABSTRACT_EXDOC_FILE_CLASS = 'COMS:CONF:PAPER:ABSTRACT_EXDOC:FILE'
			CONF_PAPER_PAPER_FILE_CLASS = 'COMS:CONF:PAPER:PAPER:FILE'
			CONF_PAPER_PAPER_EXDOC_FILE_CLASS = 'COMS:CONF:PAPER:PAPER_EXDOC:FILE'
			CONF_PAPER_PRESENTATION_FILE_CLASS = 'COMS:CONF:PAPER:PRESENTATION:FILE'
			CONF_PAPER_EXDOC_FILE_CLASS = 'COMS:CONF:PAPER:EXDOC:FILE'
			attr_reader :coll
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
				@grid = @appl.mongo.open_grid @coll_name
				class << @grid; attr_reader :_meta; end
				@collfiles = @appl.mongo.open_collection @coll_name+'.files'
			end

			def save_my_paper_data pin, cont_id, _id, data
				pin = pin.to_i
				ts = TS[]
				if _id
					@coll.update(
						{'_meta.class' => CONF_PAPER_CLASS, _id: _id, '_meta.owner' => pin, '_meta.parent' => cont_id},
						{'$set' => {text: data['text'], keywords: data['keywords'], authors: data['authors'], '_meta.mtime' => ts} }
					)
				else
					cnt = @appl.conf.next_paper_cnt cont_id
					_id = @seq[]
					@coll.insert({
						_id: _id,
						_meta: {class: CONF_PAPER_CLASS, owner: pin, parent: cont_id, paper_cnt: cnt, ctime: ts, mtime: ts},
						text: data['text'],
						keywords: data['keywords'],
						authors: data['authors']
					})
				end
				_id
			end

			def check_file_class cn
				case cn.to_s.to_sym
				when :abstract then CONF_PAPER_ABSTRACT_FILE_CLASS
				when :abstract_exdoc then CONF_PAPER_ABSTRACT_EXDOC_FILE_CLASS
				when :paper then CONF_PAPER_PAPER_FILE_CLASS
				when :paper_exdoc then CONF_PAPER_PAPER_EXDOC_FILE_CLASS
				when :presentation then CONF_PAPER_PRESENTATION_FILE_CLASS
			#	when :exdoc then CONF_PAPER_EXDOC_FILE_CLASS
				else 'INEXISTENT'
				end
			end
			def file_class_short_code cl
				case cl
			#	when CONF_PAPER_ABSTRACT_FILE_CLASS then 'a'
			#	when CONF_PAPER_PAPER_FILE_CLASS then 'p'
			#	when CONF_PAPER_PRESENTATION_FILE_CLASS then 'pr'
				when CONF_PAPER_ABSTRACT_FILE_CLASS then 'abstract'
				when CONF_PAPER_ABSTRACT_EXDOC_FILE_CLASS then 'abstract_exdoc'
				when CONF_PAPER_PAPER_FILE_CLASS then 'paper'
				when CONF_PAPER_PAPER_EXDOC_FILE_CLASS then 'paper_exdoc'
				when CONF_PAPER_PRESENTATION_FILE_CLASS then 'presentation'
			#	when CONF_PAPER_EXDOC_FILE_CLASS then 'exdoc'
				else 'inexistent'
				end
			end

			def find_my_paper_file pin, cont_id, _id, lang, cl
				pin = pin.to_i
				res = @collfiles.find_one( {'_meta.class' => check_file_class(cl), '_meta.owner' => pin, '_meta.parent' => _id, '_meta.lang' => lang} )
				res ? res['_id'] : nil
			end
			def find_my_paper_files pin, cont_id, _id, cl=nil
				pin = pin.to_i
				@collfiles.find( cl ?
					{'_meta.class' => check_file_class(cl), '_meta.owner' => pin, '_meta.parent' => _id} :
					{'_meta.owner' => pin, '_meta.parent' => _id}
				).map do |p|
					p['_id']
				end
			end
			def get_my_paper_files_list pin, cont_id, _id, cl=nil
				pin = pin.to_i
				@collfiles.find( cl ?
				       {'_meta.class' => check_file_class(cl), '_meta.owner' => pin, '_meta.parent' => _id} :
				       {'_meta.owner' => pin, '_meta.parent' => _id}
				).map do |f|
					get_file_info_from_file f
				end
			end
			def get_my_paper_file pin, cont_id, _id, lang, cl
				pin = pin.to_i
				old_id = find_my_paper_file pin, cont_id, _id, lang, cl
				old_id ? @grid.get(old_id) : nil
			end
			def get_my_paper_file_info pin, cont_id, _id, lang, cl
				get_file_info_from_file( get_my_paper_file pin, cont_id, _id, lang, cl )
			end
			def delete_my_paper_file pin, cont_id, _id, lang, cl
				pin = pin.to_i
				if @coll.find_one( {_id: _id, '_meta.class' => CONF_PAPER_CLASS, '_meta.owner' => pin, '_meta.parent' => cont_id} )
					old_id = find_my_paper_file pin, cont_id, _id, lang, cl
					@grid.delete(old_id) if old_id
				end
			end
			def put_my_paper_file pin, cont_id, _id, lang, cl, input, args={}
				pin = pin.to_i
				delete_my_paper_file pin, cont_id, _id, lang, cl
				ts = TS[]
				fid = @seq[]
				args.merge!({_id: fid, _meta: {
					class: check_file_class(cl),
					parent: _id,
					lang: lang,
					owner: pin,
					cont_id: cont_id,
					ctime: ts,
					mtime: ts
				}})
				@grid.put input, args
				fid
			end

			def get_my_paper_data pin, cont_id, _id
				pin = pin.to_i
				@coll.find_one( {_id: _id, '_meta.class' => CONF_PAPER_CLASS, '_meta.owner' => pin, '_meta.parent' => cont_id} )
			end
			def get_my_paper_decision pin, cont_id, _id
				pin = pin.to_i
				c = @coll.find_one(
					{'_meta.class' => CONF_PAPER_CLASS, '_meta.owner' => pin, '_id' => _id, '_meta.parent' => cont_id}
				)
				c && c['decision'] ? c['decision'] : {}
			end
			def delete_my_paper pin, cont_id, _id
				pin = pin.to_i
				if @coll.find_one( {_id: _id, '_meta.class' => CONF_PAPER_CLASS, '_meta.owner' => pin, '_meta.parent' => cont_id} )
					#find_my_paper_abstract_files( pin, cont_id, _id).each{ |id| @grid.delete id }
					find_my_paper_files( pin, cont_id, _id).each{ |id| @grid.delete id }
					@coll.remove( {_id: _id, '_meta.class' => CONF_PAPER_CLASS, '_meta.owner' => pin, '_meta.parent' => cont_id} )
				end
			end
			def get_my_papers_list pin, cont_id
				pin = pin.to_i
				@coll.find(
					{'_meta.class' => CONF_PAPER_CLASS, '_meta.owner' => pin, '_meta.parent' => cont_id}
				).sort( [[ '_meta.ctime', -1]] ).inject([]) do |acc,c|
					acc << {'_id' => c['_id'], '_meta' => c['_meta'],
						'text' => c['text'],
						'keywords' => c['keywords'],
						'authors' => c['authors'],
						#'files' => get_my_paper_abstract_files_list(pin, cont_id, c['_id'])
						'files' => get_my_paper_files_list(pin, cont_id, c['_id'])
					}
				end
			end

			def get_all_papers_list cont_id
			#	pin = pin.to_i
				@coll.find(
					{'_meta.class' => CONF_PAPER_CLASS, '_meta.parent' => cont_id}
				).sort( [[ '_meta.ctime', -1]] ).inject([]) do |acc,c|
					acc << {'_id' => c['_id'], '_meta' => c['_meta'],
						'text' => c['text'],
						'keywords' => c['keywords'],
						'authors' => c['authors'],
					#	'files' => get_paper_abstract_files_list(cont_id, c['_id'])
						'files' => get_paper_files_list(cont_id, c['_id'])
					}
				end
			end
			def get_papers_for_reviewing_list pin, cont_id
				pin = pin.to_i
				@coll.find(
					{'_meta.class' => CONF_PAPER_CLASS, '_meta.parent' => cont_id, 'reviewers' => pin}
				).sort( [[ '_meta.ctime', -1]] ).inject([]) do |acc,c|
					acc << {'_id' => c['_id'], '_meta' => c['_meta'],
						'text' => c['text'],
						'keywords' => c['keywords'],
						'authors' => c['authors'],
					#	'files' => get_paper_abstract_files_list(cont_id, c['_id'])
						'files' => get_paper_files_list(cont_id, c['_id'])
					}
				end
			end

			def get_papers_managed_list pin, cont_id
				pin = pin.to_i
				sl = @appl.conf.get_user_sections cont_id, pin
				@coll.find(
					{'_meta.class' => CONF_PAPER_CLASS, '_meta.parent' => cont_id, 'decision.section' => {'$in' => sl}}
				).sort( [[ '_meta.ctime', -1]] ).inject([]) do |acc,c|
					acc << {'_id' => c['_id'], '_meta' => c['_meta'],
						'text' => c['text'],
						'keywords' => c['keywords'],
						'authors' => c['authors'],
						'files' => get_paper_files_list(cont_id, c['_id'])
					}
				end
			end

			# Info
			def get_paper_info cont_id, _id
				c = @coll.find_one(
					{'_meta.class' => CONF_PAPER_CLASS, '_id' => _id, '_meta.parent' => cont_id}
				)
				{'_id' => c['_id'], '_meta' => c['_meta'],
					'text' => c['text'],
					'keywords' => c['keywords'],
					'authors' => c['authors'],
				#	'files' => get_paper_abstract_files_list(cont_id, c['_id'])
					'files' => get_paper_files_list(cont_id, c['_id'])
				}
			end
			def get_paper_owner cont_id, _id
				p = get_paper_info cont_id, _id
				p ? p['_meta']['owner'] : nil
			end

			# Reviewing
			def add_to_paper_reviewers cont_id, _id, pin
			#	p cont_id, _id, pin
				@coll.update({'_meta.class' => CONF_PAPER_CLASS, '_id' => _id, '_meta.parent' => cont_id}, {'$addToSet' => {'reviewers' => pin.to_i}, '$set' => {'_meta.mtime' => TS[]} })
			end
			def remove_from_paper_reviewers cont_id, _id, pin
				@coll.update({'_meta.class' => CONF_PAPER_CLASS, '_id' => _id, '_meta.parent' => cont_id}, {'$pull' => {'reviewers' => pin.to_i}, '$set' => {'_meta.mtime' => TS[]} })
			end
			def get_paper_reviewers cont_id, _id
				c = @coll.find_one(
					{'_meta.class' => CONF_PAPER_CLASS, '_id' => _id, '_meta.parent' => cont_id}
				)
				c && c['reviewers'] ? c['reviewers'] : []
			end
			def has_papers_for_reviewing pin, cont_id
				pin = pin.to_i
				@coll.find(
					{'_meta.class' => CONF_PAPER_CLASS, '_meta.parent' => cont_id, 'reviewers' => pin}
				).count > 0
			end
			def is_paper_reviewer pin, cont_id, _id
				pin = pin.to_i
				@coll.find_one(
					{'_meta.class' => CONF_PAPER_CLASS, '_meta.parent' => cont_id, 'reviewers' => pin, '_id' => _id}
				) ? true : false
			end

			# Decision
			def set_paper_decision cont_id, _ids, decision
				_ids = [_ids] unless _ids.is_a?(Array)
				_ids.each do |_id|
					@coll.update({'_meta.class' => CONF_PAPER_CLASS, '_id' => _id, '_meta.parent' => cont_id}, {'$set' => {'decision' => decision}})
				end
			#	@coll.update({'_meta.class' => CONF_PAPER_CLASS, '_id' => _id, '_meta.parent' => cont_id}, {'$set' => {'decision' => decision}})
			end
			def get_paper_decision cont_id, _id
				c = @coll.find_one(
					{'_meta.class' => CONF_PAPER_CLASS, '_id' => _id, '_meta.parent' => cont_id}
				)
				c && c['decision'] ? c['decision'] : {}
			end

			# ---------------
			def get_paper_files_list cont_id, _id, cl=nil
				@collfiles.find( cl ?
					{'_meta.class' => check_file_class(cl), '_meta.parent' => _id, '_meta.cont_id' => cont_id} :
					{'_meta.parent' => _id, '_meta.cont_id' => cont_id}
				).map do |f|
					get_file_info_from_file f
				end
			end
			def get_file_info_from_file f
				f ? {
					_id: f['_id'],
    					content_type: f['contentType'],
					length: f['length'],
					filename: f['filename'],
				#	uniquefilename: f['_meta']['parent']+'_a_'+f['_meta']['lang']+'_'+f['filename'],
					uniquefilename: f['_meta']['parent']+'_'+file_class_short_code(f['_meta']['class'])+'_'+f['_meta']['lang']+'_'+f['filename'],
					class_code: file_class_short_code(f['_meta']['class']),
					_meta: f['_meta']
				} : nil
			end
			def find_paper_file cont_id, _id, lang, cl
				res = @collfiles.find_one( {'_meta.class' => check_file_class(cl), '_meta.parent' => _id, '_meta.lang' => lang} )
				res ? res['_id'] : nil
			end
			def get_paper_file cont_id, _id, lang, cl
				fid = find_paper_file cont_id, _id, lang, cl
				fid ? @grid.get(fid) : nil
			end

			def _submitted_all cont_id
				@coll.find(
					{'_meta.class' => CONF_PAPER_CLASS, '_meta.parent' => (cont_id.is_a?(Array) ? {'$in' => cont_id} : cont_id)}
				)
			end
		end
	end
end


