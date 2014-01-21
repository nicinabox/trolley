module Trolley
  module Hash
    def transform_hash(original, options={}, &block)
      original.inject({}){|result, (key,value)|
        value = if (options[:deep] && Hash === value)
                  transform_hash(value, options, &block)
                else
                  value
                end
        block.call(result,key,value)
        result
      }
    end

    def stringify_keys(hash)
      transform_hash(hash) {|hash, key, value|
        hash[key.to_s] = value
      }
    end

    def deep_stringify_keys(hash)
      transform_hash(hash, :deep => true) {|hash, key, value|
        hash[key.to_s] = value
      }
    end
  end
end
