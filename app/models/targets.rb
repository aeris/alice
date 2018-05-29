class Targets < ActiveRecord::Type::Value
	class Target
		def initialize(target)
			@from = target['from']
			@to   = target['to']
			@css  = target['css']
		end

		def extract_boundary(content)
			if @from
				i = content.index @from
				raise "Unable to find `from` #{@from}" unless i
				content = content[i..-1]
			end

			if @to
				i = content.index @to
				raise "Unable to find `to` #{@to}" unless i
				content = content[0..i]
			end
			content
		end

		def extract_css(content)
			return content unless @css
			content = Nokogiri::HTML.parse content
			node    = content.at @css
			raise "Unable to find `css` #{@css}" unless node
			node.to_s
		end

		def extract(content)
			content = self.extract_boundary content
			content = self.extract_css content
			content
		end

		def to_h
			json         = {}
			json['from'] = @from if @from
			json['to']   = @to if @to
			json['css']  = @css if @css
			json
		end

		def empty?
			!(@from || @to || @css)
		end
	end

	def self.detect(object)
		targets = object['targets']
		if targets
			targets = targets.collect { |t| create t }.flatten
			return nil if targets.empty?
			targets
		end

		target = create object
		return nil unless target

		[target]
	end

	def type
		:string
	end

	def deserialize(value)
		return nil unless value
		value = YAML.load value
		value.collect { |t| Target.new t }
	end

	def serialize(value)
		return nil unless value
		value = value.collect &:to_h
		YAML.dump value
	end

	private

	def self.create(target)
		target = Target.new target
		return nil if target.empty?
		target
	end
end
