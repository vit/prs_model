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
			{type: 'CONF', title: {en: 'Physcon 2013', ru: 'Физкон 2013'}}
		end
		def get_item_children _id
			[]
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




