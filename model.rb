# coding: UTF-8

#%w[mongo time digest/sha1 unicode_utils raser/utils/db/pgconnection].each {|r| require r}
#%w[mongo time digest/sha1 unicode_utils raser/utils/db/pgconnection raser/utils/db/myconnection].each {|r| require r}
%w[mongo time digest/sha1 unicode_utils].each {|r| require r}

$:.unshift ::File.expand_path(::File.dirname __FILE__)

module Coms
	class Model
		attr_reader :mongo, :libModel, :pg, :auth, :util, :conf, :user, :country, :mail, :msg, :post, :lib
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

			puts 'model/util/util...'
			require 'model/util/util'
		#	@util = Coms::Lib.new({appl: self, coll_name: 'util'})
			@util = Coms::Util.new({appl: self})
			puts '...done'

			puts 'model/conf/model...'
			require 'model/conf/model'
			#@conf = Coms::Conf::Model.new({appl: self, coll_name: 'conf001'})
			@conf = Coms::Conf::Model.new({appl: self, coll_name: 'conf'})
			puts '...done'

			puts 'model/user/user...'
			require 'model/user/user'
			@user = Coms::User.new({appl: self, coll_name: 'user'})
			puts '...done'

			puts 'model/user/country...'
			require 'model/user/country'
			#@user = Coms::User.new({appl: self, coll_name: 'user'})
			@country = Coms::User::Country
			@country.init
			puts '...done'

			puts 'model/mail/mail...'
			require 'model/mail/mail'
			@mail = Coms::Notification.new({appl: self})
			puts '...done'

			puts 'model/post/post...'
			require 'model/post/post'
			@post = Coms::Post.new({appl: self, coll_name: 'post'})
			puts '...done'

			puts 'model/msg/msg...'
			require 'model/msg/msg'
			@msg = Coms::Msg.new({appl: self, coll_name: 'msg'})
			puts '...done'

			puts 'model/lib/lib...'
			require 'model/lib/lib'
			@lib = Coms::Lib.new({appl: self, coll_name: 'lib'})
			puts '...done'
		end
	end
end

