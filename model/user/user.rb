# coding: UTF-8

$:.unshift ::File.expand_path(::File.dirname __FILE__)
%w[country mail].each {|r| require r}
$:.shift

module Coms
	class User
		USER_COMMON_CLASS = 'COMS:USER:COMMON'
		USER_CLASS = 'COMS:USER:USER'
		attr_accessor :auth, :info
		TS = -> { Time.now.utc.iso8601(10) }
		IdSeq = -> args=({}) {
			domain = (args[:domain] || 'localhost').to_s
			limit = (args[:size] || 40).to_i - 1
			-> { ( Digest::SHA1.new << domain+rand.to_s+TS[] ).to_s[0..limit] }
		}
		def initialize attr={}
			@seq = IdSeq[domain: 'localhost', size: 12]
			@attr = attr
			@appl = attr[:appl]
			@coll_name = attr[:coll_name]
			@coll = @appl.mongo.open_collection @coll_name
			@auth = Auth.new @attr.merge({session_coll_name: @coll_name+'.session'})
			@info = Info.new @attr
		end

		def ping
			1
		end
		def new_user data
			_id = @seq[]
			ts = TS[]
			@coll.db.eval "function() {
				db.#{@coll_name}.findOne({'_meta.class': '#{USER_COMMON_CLASS}' }) ||
				db.#{@coll_name}.insert({_id: '#{_id}', _meta: {class: '#{USER_COMMON_CLASS}', ctime: '#{ts}', mtime: '#{ts}' }, admins: [1], data: {pin: 1}})
			}"
			res = @coll.find_and_modify({query: {'_meta.class' => USER_COMMON_CLASS}, update: {'$inc' => {'data.pin' => 1}, '$set' => {'_meta.mtime' => TS[]} } })
			_id = @seq[]
			pin = res['data']['pin'].to_i
			data['account']['pin'] = pin
			@coll.insert({_id: _id, _meta: {class: USER_CLASS, ctime: ts, mtime: ts}, account: data['account'], info: data['info'] })
			sendmail_registered data
			{_id: _id, pin: pin}
		end
		def get_user_email pin
			row = @coll.find_one({'_meta.class' => USER_CLASS, 'account.pin' => pin.to_i})
			(row && row['account']) ? row['account']['email'] : nil
		end
		def get_user_info pin
			row = @coll.find_one({'_meta.class' => USER_CLASS, 'account.pin' => pin.to_i})
			row ? row['info'] : nil
		end
		def get_user_info_ext pin
			row = @coll.find_one({'_meta.class' => USER_CLASS, 'account.pin' => pin.to_i})
			if row && row['info']
				row['info']['email'] = row['account']['email']
				row['info']
			else
				nil
			end
		end
		def set_user_email pin, email
			@coll.update({'_meta.class' => USER_CLASS, 'account.pin' => pin.to_i}, {'$set' => {'account.email' => email, '_meta.mtime' => TS[]} })
		end
		def set_user_password pin, oldpassword, password
			@coll.update({'_meta.class' => USER_CLASS, 'account.pin' => pin.to_i, 'account.password' => oldpassword}, {'$set' => {'account.password' => password, '_meta.mtime' => TS[]} })
		end
		def set_user_info pin, info
			@coll.update({'_meta.class' => USER_CLASS, 'account.pin' => pin.to_i}, {'$set' => {'info' => info, '_meta.mtime' => TS[]} })
		end
		def find_users query
			@coll.find({'_meta.class' => USER_CLASS, '$or' => [{'info.lname.en' => query}, {'info.lname.ru' => query}]}).limit(100).map{ |row|
			#@coll.find({'_meta.class' => USER_CLASS, '$or' => [{'account.pin' => query.to_i}]}).limit(100).map{ |row|
				{
					account: {pin: row['account']['pin']},
					info: row['info']
				}
			}
		end
		def add_to_admins_list pin
			@coll.update({'_meta.class' => USER_COMMON_CLASS}, {'$addToSet' => {'admins' => pin.to_i}, '$set' => {'_meta.mtime' => TS[]} })
		end
		def remove_from_admins_list pin
			@coll.update({'_meta.class' => USER_COMMON_CLASS}, {'$pull' => {'admins' => pin.to_i}, '$set' => {'_meta.mtime' => TS[]} })
		end
		def get_admins_list
			@coll.find_one({'_meta.class' => USER_COMMON_CLASS})['admins']
		end
		def is_admin pin
			@coll.find_one({'_meta.class' => USER_COMMON_CLASS, 'admins' => pin.to_i}) ? true : false
		end
		def restore_password data
			pin = data['pin'].strip
			email = data['email'].strip
			lname = data['lname'].strip
			pin = pin.empty? ? nil : pin.to_i
			email = email.empty? ? nil : email
			lname = lname.empty? ? nil : lname
			row = nil
			status = 'not_found'
			if pin && email
				row = @coll.find_one({'_meta.class' => USER_CLASS, 'account.pin' => pin, 'account.email' => email})
			end
			if !row && pin && lname
				row = @coll.find_one({'_meta.class' => USER_CLASS, 'account.pin' => pin, '$or' => [{'info.lname.en' => lname}, {'info.lname.ru' => lname}]})
			end
			if !row && email && lname
				row = @coll.find_one({'_meta.class' => USER_CLASS, 'account.email' => email, '$or' => [{'info.lname.en' => lname}, {'info.lname.ru' => lname}]})
			end
			if row
				sendmail_restore row
				status = 'found'
			end
			{status: status}
		end

		def sendmail_restore data

			@appl.post.send_email_to_user_for_slot data['account']['pin'], 'account', 'restore', {}

			text = <<-"END";
			English text see below.

			Уважаемый #{data['info']['title']['ru']} #{data['info']['fname']['ru']} #{data['info']['mname']['ru']} #{data['info']['lname']['ru']}!
			Вы получили это письмо, поскольку было запрошено восстановление пароля.

			Ваш PIN: "#{data['account']['pin']}".
			Пароль: "#{data['account']['password']}".

			С уважением,
			СПОК-Электроприбор.

			Система находится по адресу http://comsep.ru.

			*****

			Dear #{data['info']['title']['en']} #{data['info']['fname']['en']} #{data['info']['mname']['en']} #{data['info']['lname']['en']}!

			Your PIN is "#{data['account']['pin']}".
			Password is "#{data['account']['password']}".

			Sincerely
			CoMS-Elektropribor

			System address: http://comsep.ru.

			END
			subj = 'Password recovery | Восстановление пароля'

			mail = Mail.new do
				from 'system@comsep.ru'
				to data['account']['email']
				subject subj
				body text
			end
			mail.charset = 'UTF-8'
			mail.delivery_method :sendmail
			mail.deliver

		#	p mail.to_s

		end
		def sendmail_registered data

			text = <<-"END";
			English text see below.

			Уважаемый #{data['info']['title']['ru']} #{data['info']['fname']['ru']} #{data['info']['mname']['ru']} #{data['info']['lname']['ru']}!

			Вы зарегистрированы в системе СПОК-Электроприбор.
			Вам присвоен PIN "#{data['account']['pin']}" и назначен пароль "#{data['account']['password']}".

			Если Вы сами не регистрировались, значит кто-то это сделал за Вас.

			С уважением,
			СПОК-Электроприбор.

			Система находится по адресу http://comsep.ru.

			*****

			Dear #{data['info']['title']['en']} #{data['info']['fname']['en']} #{data['info']['mname']['en']} #{data['info']['lname']['en']}!

			You have been registered in the system CoMS-Elektropribor with PIN "#{data['account']['pin']}".
			Your password is "#{data['account']['password']}".

			Sincerely
			CoMS-Elektropribor

			System address: http://comsep.ru.

			END
			subj = 'Notification of registration | Уведомление о регистрации в системе'

			mail = Mail.new do
				from 'system@comsep.ru'
				to data['account']['email']
				subject subj
				body text
			end
			mail.charset = 'UTF-8'
			mail.delivery_method :sendmail
			mail.deliver

		#	p mail.to_s

		end

		class Info
			def initialize attr
				@attr = attr
				@appl = @attr[:appl]
				@coll_name = attr[:coll_name]
				@coll = @appl.mongo.open_collection @coll_name
				@titles = []
			end
		#	def get_user_info user_id, lang_code
		#	end
			def get_user_info_ml pin
				row = @coll.find_one({'_meta.class' => USER_CLASS, 'account.pin' => pin})
				(row && row['info']) ? %w[en ru].inject({}) do |res,lang|
					rl = {}
					row['info'].each_pair do |k,v|
						rl[k] = v.is_a?(Hash) ? v[lang] : v
					end
					rl['fullname'] = sprintf "%s %s %s %s", rl['title'], rl['fname'], rl['mname'], rl['lname']
					res[lang] = rl
					res
				end : {}
			end
		end
		class Auth
			USER_SESSION_CLASS = 'COMS:USER:SESSION'
			def initialize attr
				@seq = IdSeq[domain: 'localhost', size: 12]
				@attr = attr
				@appl = attr[:appl]
				@coll_name = attr[:coll_name]
				@coll = @appl.mongo.open_collection @coll_name
				@session_coll_name = attr[:session_coll_name]
				@session_coll = @appl.mongo.open_collection @session_coll_name
			end
			def checkSessionKey key
				res = nil
				row = @session_coll.find_one({'_meta.class' => USER_SESSION_CLASS, _id: key})
				if row
					if ( Time.now.utc-Time.parse(row['_meta']['mtime']) ) > 3600
						@session_coll.remove({'_meta.class' => USER_SESSION_CLASS, _id: key})
					else
						@session_coll.update({'_meta.class' => USER_SESSION_CLASS, _id: key}, {'$set' => {'_meta.mtime' => TS[]}})
						res = row['pin'].to_i
					end
				end
				res
			end
			def checkUser pin, password
				row = @coll.find_one({'_meta.class' => USER_CLASS, 'account.pin' => pin.to_i, 'account.password' => password})
				row ? row['account']['pin'].to_i : nil
			end
			def createSessionKey pin
				key = @seq[]
				ts = TS[]
				@session_coll.insert({_id: key, pin: pin.to_i, _meta: {class: USER_SESSION_CLASS, ctime: ts, mtime: ts}})
				key
			end
			def userEnter pin, password
				createSessionKey(checkUser(pin, password))
			end
			def checkUserAndCreateSessionKey id, password
				0
			end
			def dropSessionKey key
				@session_coll.remove({'_meta.class' => USER_SESSION_CLASS, _id: key})
			end
		end
	end
end




