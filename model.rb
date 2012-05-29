# coding: UTF-8

#%w[mongo time digest/sha1 unicode_utils raser/utils/db/pgconnection].each {|r| require r}
#%w[mongo time digest/sha1 unicode_utils raser/utils/db/pgconnection raser/utils/db/myconnection].each {|r| require r}
%w[mongo time digest/sha1 unicode_utils].each {|r| require r}

$:.unshift ::File.expand_path(::File.dirname __FILE__)

module Coms
	class Model
		attr_reader :mongo, :libModel, :pg, :auth, :conf, :user, :mail
		def initialize config=nil
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
=begin
	class Model
		attr_reader :mongo, :pg, :sphinx, :lib, :coms
		def initialize config={}
			if config['mongo'] && config['mongo']['host'] && config['mongo']['dbname']
				@mongo = Mongo::Connection.new(config['mongo']['host']).db(config['mongo']['dbname'])
			end
			if config['pg']
				@pg = Raser::Db::PgConnection.new(config['pg'])
				@pg.query "SET CLIENT_ENCODING TO 'WIN1251';"
			end
			if config['sphinx']
				@sphinx = Raser::Db::MyConnection.new(config['sphinx'])
			end
			@lib = Lib.new self, config
			@coms = Coms.new self, config
		end
	end
=end
end

