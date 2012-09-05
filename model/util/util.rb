# coding: UTF-8

$:.unshift ::File.expand_path(::File.dirname __FILE__)
%w[mail].each {|r| require r}
$:.shift

module Coms
	class Util
		def initialize attr={}
			@attr = attr
			@appl = attr[:appl]
		end

		def get_dict name, lang
			{
				q: 'qqq',
				w: 'www'
			}
			#TranslationLoader.get_translation lang, name
			TranslationLoader.get_locale_data lang, name
		end
	end
end




