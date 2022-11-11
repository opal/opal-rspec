module RSpec
  module Support
    class Differ
      def hash_to_string(hash)
        formatted_hash = ObjectFormatter.prepare_for_inspection(hash)
        formatted_hash.keys.sort_by { |k| k.to_s }.map do |key|
          pp_key   = PP.singleline_pp(key, [])
          pp_value = PP.singleline_pp(formatted_hash[key], [])

          "#{pp_key.join} => #{pp_value.join},"
        end.join("\n")
      end

      def object_to_string(object)
        object = @object_preparer.call(object)
        case object
        when Hash
          hash_to_string(object)
        when Array
          PP.pp(ObjectFormatter.prepare_for_inspection(object), []).join
        when String
          object =~ /\n/ ? object : object.inspect
        else
          PP.pp(object, []).join
        end
      end
    end
  end
end
