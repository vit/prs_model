# coding: UTF-8

$:.unshift ::File.expand_path(::File.dirname __FILE__)
#%w[mail].each {|r| require r}
$:.shift

module Coms
	class Msg
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
		end
		def get_my_object_thread pin, cont_id, paper_id
		#	@appl.conf.paper.get_paper_owner(cont_id, paper_id) == pin.to_i ? @coll.find({
		#		'_meta.class' => CONF_REVIEW_CLASS, '_meta.parent' => cont_id, '_meta.paper_id' => paper_id
		#	}).map do |r|
		#		{
		#			'data' => (r['data'] ? {'authcomments' => r['data']['authcomments']} : {})
		#		}
		#	end : []
			[]
		end


=begin
		def send_notification name, lang, args={}
			udata = @appl.user.get_user_info_ext args[:receiver_pin]
			pdata = @appl.conf.paper.get_paper_info args[:cont_id], args[:paper_id]

			file_type_text = case args[:file_type]
			when 'abstract' then {ru: 'реферат', en: 'abstract'}
			when 'paper' then {ru: 'доклад', en: 'paper'}
			when 'presentation' then {ru: 'презентация', en: 'presentation'}
			else {ru: 'файл неясного типа', en: 'unknown type file'}
			end

			if name == :files_uploaded
				text = <<-"END";
				ENGLISH TEXT SEE BELOW.

				Уважаемый #{udata['title']['ru']} #{udata['fname']['ru']} #{udata['mname']['ru']} #{udata['lname']['ru']}!

				Ваш #{file_type_text[:ru]} № #{pdata['_meta']['paper_cnt']} успешно передан в Оргкомитет конференции.

				С уважением,
				СПОК-Электроприбор.

				Система находится по адресу http://comsep.ru.

				*****

				Dear #{udata['title']['en']} #{udata['fname']['en']} #{udata['mname']['en']} #{udata['lname']['en']}!

				Your #{file_type_text[:en]} \# #{pdata['_meta']['paper_cnt']} is passed to the organizing committee successfully.

				Sincerely
				CoMS-Elektropribor

				System address: http://comsep.ru.

				END
				subj = 'Notification :: Files uploaded | Уведомление :: Файлы загружены'

				mail = Mail.new do
					from 'system@comsep.ru'
					to udata['email']
					#to 'shiegin@gmail.com'
					subject subj
					body text
				end
				mail.charset = 'UTF-8'
				mail.delivery_method :sendmail
				mail.deliver
			end
		end

=end
	end

end

