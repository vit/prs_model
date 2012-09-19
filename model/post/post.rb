# coding: UTF-8

%w[erb mail ].each {|r| require r}

$:.unshift ::File.expand_path(::File.dirname __FILE__)
%w[producer].each {|r| require r}
$:.shift

module Coms
	class Post
		attr_accessor :producer
		POST_TEMPLATE_CLASS = 'COMS:POST:TEMPLATE'
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
			@producer = Producer.new({appl: @appl, coll_name: @coll_name+'.producer'})
		end

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

		# ########################################

		def get_template_for_slot category, name, args={}
			Template.new (
				{
					'subject' => '001 Password recovery | Восстановление пароля',
					'text' => (<<-"END";
						English text see below.
						<%= @user.to_s %>
						<%= qqq %>
					END
					)
				}
			)
		end
		def send_email_to_user_for_slot pin, category, name, args={}
			user_info = @appl.user.get_user_info_ext pin
			template = get_template_for_slot category, name, args
			msg = template.apply({user: user_info})

			mail = Mail.new do
				from 'system@comsep.ru'
			#	to data['account']['email']
				to 'shiegin@gmail.com'
				subject msg['subject']
				body msg['text']
			end
			mail.charset = 'UTF-8'
			mail.delivery_method :sendmail
			mail.deliver

		end

		class Template
			class Context
				def initialize data
					@data = data
					data.each_pair do |key, value|
						instance_variable_set('@' + key.to_s, value)
					end
				end
				def qqq
					'qwerqreyrutyi'
				end
			end
			def initialize t
				@t = t
			end
			def apply data={}
				c = Context.new data
				{
					'subject' => ERB.new(@t['subject']).result(c.instance_eval { binding }),
					'text' => ERB.new(@t['text']).result(c.instance_eval { binding })
				}
			#	@t
			end
			def to_s
				@t.to_s
			end
		end


	end
end




