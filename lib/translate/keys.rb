class Translate::Keys
  # Convert something like:
  #
  #  {'pressrelease.label.one' => "Pressmeddelande"}
  #
  # to:
  #
  # {
  #  :pressrelease => {
  #    :label => {
  #      :one => "Pressmeddelande"
  #    }
  #   }
  # }
  def self.to_deep_hash(hash)
    hash.inject({}) do |deep_hash, (key, value)|
      keys = key.to_s.split('.').reverse
      leaf_key = keys.shift
      key_hash = keys.inject({leaf_key.to_sym => try_undump_value(value)}) { |hash, key| {key.to_sym => hash} }
      deep_merge!(deep_hash, key_hash)
      deep_hash
    end
  end

  def self.try_undump_value(value)
    begin
      raise "Not YAML" if (value =~ /---/) != 0
      YAML.load(value)
    rescue
      begin
        Integer(value)
      rescue
        begin
          Float(value)
        rescue
          value
        end
      end
    end
  end

  # Convert something like:
  #
  # {
  # :pressrelease => {
  # :label => {
  # :one => "Pressmeddelande"
  # }
  # }
  # }
  #
  # to:
  #
  # {'pressrelease.label.one' => "Pressmeddelande"}
  #
  def self.to_shallow_hash(hash)
    hash.inject({}) do |shallow_hash, (key, value)|
      if value.is_a?(Hash)
        to_shallow_hash(value).each do |sub_key, sub_value|
          shallow_hash[[key, sub_key].join(".")] = sub_value
        end
      else
        shallow_hash[key.to_s] = value
      end
      shallow_hash
    end
  end

  private
  # deep_merge by Stefan Rusterholz, see http://www.ruby-forum.com/topic/142809
  def self.deep_merge!(hash1, hash2)
    merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    hash1.merge!(hash2, &merger)
  end
end
