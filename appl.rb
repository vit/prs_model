
$:.unshift ::File.expand_path(::File.dirname __FILE__)

module Coms
	class Appl
		attr_reader :mongo, :libModel, :pg, :auth, :conf, :user, :mail
		def initialize
			puts 'raser/utils/db/mongoconnection...'
			require 'raser/utils/db/mongoconnection'
			@mongo = Raser::Db::MongoConnection.new do |m|
				m.host = '127.0.0.1'
			#	m.db_name = 'lib-db'
				m.db_name = 'coms'
			end
			puts '...done'

		#	puts 'coms/model/lib/modelmongo...'
		#	require 'coms/model/lib/modelmongo'
		#	file_path = '/home/vit/data/coms.pribor.new/files/mongo/'
		#	@libModel = Coms::Lib::ModelMongo.new do |m|
		#		m.conn = @mongo
		#		m.filePath = file_path
		#		m.coll_name = 'lib'
		#	end
		#	puts '...done'

			puts 'model/conf/model...'
			require 'model/conf/model'
			#@conf = Coms::Conf::Model.new({appl: self, coll_name: 'conf001'})
			@conf = Coms::Conf::Model.new({appl: self, coll_name: 'conf'})
			puts '...done'

			puts 'model/user/user...'
			require 'model/user/user'
			@user = Coms::User.new({appl: self, coll_name: 'user'})
			puts '...done'

			puts 'model/mail/mail...'
			require 'model/mail/mail'
			@mail = Coms::Notification.new({appl: self})
			puts '...done'
		end
	end
end

#$:.shift


