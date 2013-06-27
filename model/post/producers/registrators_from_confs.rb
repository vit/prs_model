

main do |args|

		if args && args['confs'] && args['confs'].is_a?(Array)
			@appl.conf.paper._submitted_all(args['confs']).map do |p|
				p['_meta']['owner'].to_i
			end.uniq.map do |p|
				{'pin =>' p}
			end
		else
			[]
		end
end


