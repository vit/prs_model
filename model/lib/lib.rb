# coding: UTF-8

$:.unshift ::File.expand_path(::File.dirname __FILE__)
%w[].each {|r| require r}
$:.shift

module Coms
	class Lib
		LIB_ITEM_CLASS = 'COMS:LIB:ITEM'
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
		def get_id_by_alias a
			1
		end
		def get_item_data _id
		#	res = @coll.find_one( {_id: _id, '_meta.class' => LIB_ITEM_CLASS} )
		#	res && res['data'] ? res['data'] : {}
			case _id
			when '1' then {'type' => 'CONF:LIST', 'title' => {'en' => 'Conferences list', 'ru' => 'Список конференций'}}
			when '11' then {'type' => 'CONF:ITEM', 'title' => {'en' => 'ICINS 2013', 'ru' => 'МКИНС 2013'}}
			when '12' then {'type' => 'CONF:ITEM', 'title' => {'en' => 'ICINS 2012', 'ru' => 'МКИНС 2012'}}
			when '13' then {'type' => 'CONF:ITEM', 'title' => {'en' => 'ICINS 2011', 'ru' => 'МКИНС 2011'}}
			when '111' then {'type' => 'CONF:PAPER', 'title' => {'en' => 'Paper 001', 'ru' => 'Статья 001'}}
			when '112' then {'type' => 'CONF:PAPER', 'title' => {'en' => 'Paper 002', 'ru' => 'Статья 002'}}
			else {}
			end
		end
		def get_item_children _id
			case _id
			when '1' then [
				{'id' => 11, 'type' => 'CONF:ITEM', 'title' => {'en' => 'ICINS 2013', 'ru' => 'МКИНС 2013'}},
				{'id' => 12, 'type' => 'CONF:ITEM', 'title' => {'en' => 'ICINS 2012', 'ru' => 'МКИНС 2012'}},
				{'id' => 13, 'type' => 'CONF:ITEM', 'title' => {'en' => 'ICINS 2011', 'ru' => 'МКИНС 2011'}}
			]
			when '11' then [
				{'id' => 111, 'type' => 'CONF:PAPER', 'title' => {'en' => 'Paper 001', 'ru' => 'Статья 001'}},
				{'id' => 112, 'type' => 'CONF:PAPER', 'title' => {'en' => 'Paper 002', 'ru' => 'Статья 002'}},
			]
			else []
			end
		end

=begin

		def get_templates cont_id
			@coll.find(
				{'_meta.class' => POST_TEMPLATE_CLASS, '_meta.context' => cont_id}
			).sort( [[ '_meta.ctime', -1]] ).inject([]) do |acc,c|
				acc << {
					'_id' => c['_id'],
					'title' => c['data']['title'],
	#		#		'data' => c['data']
				}
			end
		end
		def get_template_data cont_id, template_id
			res = @coll.find_one( {_id: template_id, '_meta.class' => POST_TEMPLATE_CLASS, '_meta.context' => cont_id} )
			res && res['data'] ? res['data'] : {}
		end
		def save_template_data cont_id, template_id, data
			ts = TS[]
			if template_id
				@coll.update(
					{'_id' => template_id, '_meta.class' => POST_TEMPLATE_CLASS, '_meta.context' => cont_id},
					{'$set' => {'data' => data, '_meta.mtime' => ts}}
				)
			else
				template_id = @seq[]
				msg = {
					_id: template_id,
					_meta: {class: POST_TEMPLATE_CLASS, context: cont_id, ctime: ts, mtime: ts},
					data: data
				}
				@coll.insert( msg )
			end
			template_id
		end
		def delete_template cont_id, template_id
			if @coll.find_one( {_id: template_id, '_meta.class' => POST_TEMPLATE_CLASS, '_meta.context' => cont_id} )
				@coll.remove( {_id: template_id, '_meta.class' => POST_TEMPLATE_CLASS, '_meta.context' => cont_id} )
			end
		end
=end

	end
end




