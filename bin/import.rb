#!./bin/rails runner
import = YAML.load_file ARGV.first

def create_target(parent, params)
	css  = params['css']
	from = params['from']
	to   = params['to']
	return nil unless css || from || to
	parent.targets.create! name: params['name'],
						   css:  css,
						   from: from, to: to
end

def create_targets(parent, params)
	targets = params['targets']
	return targets.collect { |t| create_target parent, t } if targets
	target = create_target parent, params
	return nil unless target
	[target]
end

def import_templates(templates)
	return unless templates
	templates.each do |name, params|
		puts "Importing template #{name.colorize :yellow}"
		begin
			template = Template.create! name: name
			create_targets template, params
		rescue => e
			$stderr.puts "Unable to import template #{name.colorize :yellow}: #{e.to_s.colorize :red}"
		end
	end
end

def import_groups(groups)
	return unless groups
	groups.each do |name, params|
		puts "Importing group #{name.colorize :yellow}"

		template_name = params['template']
		template      = Template[template_name] if template_name
		$stderr.puts "Template #{template_name.colorize :yellow} not found for group #{name.colorize :yellow}" if template_name && !template

		begin
			group = Group.create! name: name, template: template
			create_targets group, params
		rescue => e
			$stderr.puts "Unable to import group #{name.colorize :yellow}: #{e.to_s.colorize :red}"
			next
		end

		import_sites params['sites'], group
	end
end

def import_sites(sites, group = nil, skip_title: true)
	return unless sites
	sites.each do |params|
		case params
		when String
			url    = params
			params = {}
		else
			url = params['url']
		end
		puts "Importing site #{url.colorize :yellow}"

		begin
			name = params['name']
			name ||= Site.title url unless skip_title

			template_name = params['template']
			template      = Template[template_name] if template_name
			$stderr.puts "Template #{template_name.colorize :yellow} not found for site #{url.colorize :yellow}" if template_name && !template

			unless group
				group_name = params['group']
				group      = Group[group_name] if group_name
				$stderr.puts "Group #{group_name.colorize :yellow} not found for site #{url.colorize :yellow}" if group_name && !group
			end

			site = Site.create! url: url, name: name, group: group
			create_targets site, params
			site.create_checks!
		rescue => e
			$stderr.puts "Unable to import site #{url.colorize :yellow}: #{e.to_s.colorize :red}"
			raise
		end
	end
end

ActiveRecord::Base.transaction do
	Check.destroy_all
	Target.destroy_all
	Site.destroy_all
	Group.destroy_all
	Template.destroy_all

	import_templates import['templates']
	import_groups import['groups']
	import_sites import['sites']
end
