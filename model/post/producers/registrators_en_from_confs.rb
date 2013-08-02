
main do |args|

		if args && args['confs'] && args['confs'].is_a?(Array)
			@appl.conf.paper._submitted_all(args['confs']).map do |p|
				p['_meta']['owner'].to_i
			end.uniq.map do |p|
				{'pin' => p}
			end.select do |data|
				user = @appl.user.get_user_info( data['pin'] )
				not ['ru', 'be', 'ua'].include?(user['country'])
			end
		else
			[]
		end
end

