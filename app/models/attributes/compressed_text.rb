require 'xz'
require 'active_record/connection_adapters/postgresql_adapter'

class CompressedText < ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Bytea
	def type
		:compressed_text
	end

	def serialize(value)
		return if value.nil?
		value = XZ.compress value, level: 9
		super value
	end

	def deserialize(value)
		return if value.nil?
		XZ.decompress super
	end
end
