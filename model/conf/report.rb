# coding: UTF-8

module Coms
	module Conf
		class Report
			attr_accessor :appl
			def initialize attr={}
				@appl = attr[:appl]
			end
			def get_reports_list cont_id
				{
					report_1: {title: :report_1},
					report_2: {title: :report_2},
					abstracts_by_country: {title: :abstracts_by_country},
					abstracts_with_files: {title: :abstracts_with_files},
					abstracts_with_paper_files: {title: :abstracts_with_paper_files},
					abstract_ids_with_files: {title: :abstract_ids_with_files},
					papers_statistics: {title: :papers_statistics},
					papers_statistics_after_decision: {title: :papers_statistics_after_decision},
					papers_list_with_reviews: {title: :papers_list_with_reviews},
					papers_list_with_reviews2: {title: :papers_list_with_reviews2},
					authors_list: {title: :authors_list},
					registrators_list: {title: :registrators_list},
					reviewers_list: {title: :reviewers_list},
					papers_by_section: {title: :papers_by_section},
					participation_forms: {title: :participation_forms}
				}
			end
			def bycountry cont_id
				@appl.conf.paper._submitted_all(cont_id).inject({}){ |acc,p|
					c = @appl.user.get_user_info( p['_meta']['owner'] )['country']
					acc[c] ||= 0
					acc[c] += 1
					acc
				}
			end
			def get_summary cont_id, lang_code
				data = @appl.conf.get_conf_data cont_id
				{
					context_id: cont_id,
					context_homepage: data['info']['homepage'][lang_code],
					context_title: data['info']['title'][lang_code],
					papcnt: @appl.conf.paper._submitted_all(cont_id).count,
					countrycnt: bycountry(cont_id).keys.count
				}
			end

			def papers_full_list cont_id, lang_code
				@appl.conf.paper._submitted_all( cont_id ).inject([]) do |acc,c|
					acc << {'_id' => c['_id'], '_meta' => c['_meta'],
						'text' => c['text'],
						'keywords' => c['keywords'],
						'authors' => c['authors'],
						'decision' => c['decision'] ? c['decision'] : {},
					#	'files' => @appl.conf.paper.get_paper_abstract_files_list(cont_id, c['_id']),
						'files' => @appl.conf.paper.get_paper_files_list(cont_id, c['_id']),
						'owner_info' => @appl.user.get_user_info(c['_meta']['owner'])
					}
				end.sort{ |a,b| a['_meta']['paper_cnt'] <=> b['_meta']['paper_cnt'] }
			end
			def abstracts_by_country cont_id, lang_code
				papers_full_list( cont_id, lang_code ).inject({}) do |acc, p|
					cc = p['owner_info']['country']
				#	p cc
					acc[ cc ] ||= []
					acc[ cc ] << p
					acc
				end.to_a
			end
			def papers_by_section cont_id, lang_code
				papers_full_list( cont_id, lang_code ).inject({}) do |acc, p|
					sec = p['decision'] && p['decision']['section'] ? p['decision']['section'] : nil
				#	p cc
					acc[ sec ] ||= []
					acc[ sec ] << p
					acc
				#end.to_a
				end
			end
			def abstracts_with_files cont_id, lang_code
				papers_full_list( cont_id, lang_code )
			end
			def abstracts_with_paper_files cont_id, lang_code
				papers_full_list( cont_id, lang_code )
			end

			def papers_statistics cont_id, lang_code
				{
					'context_id' => cont_id,
					'timestamp' => DateTime.now,
					'papcnt' => @appl.conf.paper._submitted_all(cont_id).count,
					'countrycnt' => bycountry(cont_id).keys.count,
					'clist' => bycountry(cont_id).to_a.map{ |a,b| {'cname' => a, 'cnt' => b} }
				}
			end
			def papers_statistics_after_decision cont_id, lang_code
				{
					'context_id' => cont_id,
					'timestamp' => DateTime.now,
					'papcnt' => @appl.conf.paper._submitted_all(cont_id).count,
					'countrycnt' => bycountry(cont_id).keys.count,
					'tbd' => {},
					'sbd' => {},
				#	'dnames' => {},
				#	'dnames' => @appl.conf.review.get_all_decisions(cont_id),
					'decisions' => -> {
					#	dh = ([:uncertain]+@appl.conf.review.get_all_decisions(cont_id)).inject({}) do |acc, d|
						dh = ([:uncertain]+@appl.conf.get_all_decisions(cont_id)).inject({}) do |acc, d|
							acc[d] = 0
							acc
						end
						@appl.conf.paper._submitted_all(cont_id).inject( dh ) do |acc, p|
							d = (p['decision'] && p['decision']['decision'] && p['decision']['decision'].to_s.length>0 ? p['decision']['decision'] : 'uncertain').to_sym
							acc[d] ||= 0
							acc[d] += 1
							acc
						end
					#	@appl.conf.paper._submitted_all(cont_id).each do |p|
					#		d = (p['decision'] && p['decision']['decision'] ? p['decision']['decision'] : 'uncertain').to_sym
					#		dh[d] ||= 0
					#		dh[d] += 1
					#	end
					#	dh
					}[],
					'sections' => (-> {
						sl = ([{'id' => :uncertain}]+@appl.conf.get_conf_sections(cont_id)).map do |s|
							{'info' => s, 'decisions' => {}}
						end
						smap = sl.inject({}) do |acc, ss|
							acc[ss['info']['id']] = ss
							acc
						end
						@appl.conf.paper._submitted_all(cont_id).each do |p|
							sec = p['decision'] && p['decision']['section'] && p['decision']['section'].length>0 ? p['decision']['section'] : :uncertain
							sec = :uncertain unless smap[sec]
						#	p sec
							if smap[sec]
								smap[sec]['decisions'] ||= {}
								d = (p['decision'] && p['decision']['decision'] && p['decision']['decision'].to_s.length>0 ? p['decision']['decision'] : 'uncertain').to_sym
								smap[sec]['decisions'][d] ||= 0
								smap[sec]['decisions'][d] += 1
								#dh[]
							end
						#	d = (p['decision'] && p['decision']['decision'] && p['decision']['decision'].to_s.length>0 ? p['decision']['decision'] : 'uncertain').to_sym
						#	acc[d] ||= 0
						#	acc[d] += 1
						#	acc['decision'] = sec
						#	acc
						end
						sl
					}[]),
					'snames' => {}
				}
			end
			def papers_list_with_reviews cont_id, lang_code
				{
				#	'papers' => @appl.conf.paper._submitted_all(cont_id).inject({}) do |acc, p|
					'papers' => @appl.conf.paper._submitted_all(cont_id).map do |p|
					#	acc[ p['_meta']['paper_cnt'] ] = {
						{
							'registrator_data' => (-> do
								pin = p['_meta']['owner']
								u = @appl.user.get_user_info_ext(pin) || {}
								rez = {}
								rez['pin'] = pin
								u['lname'] ||= {}
								u['fname'] ||= {}
								u['mname'] ||= {}
								u['affiliation'] ||= {}
								u['city'] ||= {}
								rez['phone'] = u['phone']
								rez['fax'] = u['fax']
								rez['affiliation'] = u['affiliation'][lang_code]
								rez['city'] = u['city'][lang_code]
								rez['email'] = u['email']
								rez['user_name'] = sprintf('%s %s %s', u['fname'][lang_code], u['mname'][lang_code], u['lname'][lang_code])
							#	rez['country_name'] = u['country']
								rez['country'] = u['country'] || ''
								rez
							end[]),
							'authors_data' => p['authors'].map do |a|
								{
									'user_name' => sprintf('%s %s %s', a['fname'][lang_code], a['mname'][lang_code], a['lname'][lang_code]),
									'short_user_name' => sprintf('%s%s %s',
										a['fname'][lang_code] && a['fname'][lang_code].length>0 ? a['fname'][lang_code][0]+'.' : '',
										a['mname'][lang_code] && a['mname'][lang_code].length>0 ? a['mname'][lang_code][0]+'.' : '',
										a['lname'][lang_code]
									),
									'phone' => '',
									'fax' => '',
									'email' => '',
									'country' => a['country'] || '',
									'city' => a['city'][lang_code],
									'affiliation' => a['affiliation'][lang_code],
									'user_id' => ''
								}
							end,
						#	'reviews_data' => [],
							'reviews_data' => @appl.conf.review.get_paper_reviews_ext(cont_id, p['_id']).map{ |r|
							#	r['data']['score'] ||= 'uncertain'
							#	r['data']['decision'] ||= 'uncertain'
								r['data']['score'] = 'uncertain' unless r['data']['score'].to_s.length>0
								r['data']['decision'] = 'uncertain' unless r['data']['decision'].to_s.length>0
								u = r['reviewer']
								#u['user_name'] = sprintf('%s %s %s', u['fname'][lang_code], u['mname'][lang_code], u['lname'][lang_code])
								u['user_name'] = sprintf('%s %s %s',
									(u['fname'][lang_code] ? u['fname'][lang_code][0] : ''),
									(u['mname'][lang_code] ? u['mname'][lang_code][0] : ''),
									u['lname'][lang_code]
								)
								r
							},
							'paper_id' => p['_id'],
							'paper_cnt' => p['_meta']['paper_cnt'],
							'title' => p['text']['title'][lang_code]
						}
					#	acc
					end.sort{ |a,b| a['paper_cnt'] <=> b['paper_cnt'] }
				}
			end
			def papers_list_with_reviews2 cont_id, lang_code
				papers_list_with_reviews cont_id, lang_code
			end
			def authors_list cont_id, lang_code
				papers_list_with_reviews cont_id, lang_code
			end
			def registrators_list cont_id, lang_code
				papers_list_with_reviews cont_id, lang_code
			end
			def reviewers_list cont_id, lang_code
				{
					'reviewers' =>@appl.conf.paper._submitted_all(cont_id).inject([]) do |acc, p|
						acc = acc + p['reviewers'] if p['reviewers'].is_a? Array
						acc.uniq
					end.sort.map do |pin|
					#	u = @appl.user.get_user_info(pin) || {}
						u = @appl.user.get_user_info_ext(pin) || {}
						rez = {}
						rez['pin'] = pin
						u['lname'] ||= {}
						u['fname'] ||= {}
						u['mname'] ||= {}
						u['affiliation'] ||= {}
						u['city'] ||= {}
						rez['phone'] = u['phone']
						rez['fax'] = u['fax']
						rez['affiliation'] = u['affiliation'][lang_code]
						rez['city'] = u['city'][lang_code]
						rez['email'] = u['email']
						rez['user_name'] = sprintf('%s %s %s', u['fname'][lang_code], u['mname'][lang_code], u['lname'][lang_code])
					#	rez['country_name'] = u['country']
						rez['country'] = u['country'] || ''
					#	rez['country_name'] = u.inspect
						rez
					end
				}
			end
			def participation_forms cont_id, lang_code
				{
					'forms' => @appl.conf.participation._submitted_all(cont_id).inject([]) do |acc, p|
						acc << {
							'data' => p['data']
						}
#						= acc + p['reviewers'] if p['reviewers'].is_a? Array
#					#	acc.uniq
						acc
					end
				}
=begin
				{
					'reviewers' =>@appl.conf.paper._submitted_all(cont_id).inject([]) do |acc, p|
						acc = acc + p['reviewers'] if p['reviewers'].is_a? Array
						acc.uniq
					end.sort.map do |pin|
					#	u = @appl.user.get_user_info(pin) || {}
						u = @appl.user.get_user_info_ext(pin) || {}
						rez = {}
						rez['pin'] = pin
						u['lname'] ||= {}
						u['fname'] ||= {}
						u['mname'] ||= {}
						u['affiliation'] ||= {}
						u['city'] ||= {}
						rez['phone'] = u['phone']
						rez['fax'] = u['fax']
						rez['affiliation'] = u['affiliation'][lang_code]
						rez['city'] = u['city'][lang_code]
						rez['email'] = u['email']
						rez['user_name'] = sprintf('%s %s %s', u['fname'][lang_code], u['mname'][lang_code], u['lname'][lang_code])
					#	rez['country_name'] = u['country']
						rez['country'] = u['country'] || ''
					#	rez['country_name'] = u.inspect
						rez
					end
				}
=end
			end
		end
	end
end
