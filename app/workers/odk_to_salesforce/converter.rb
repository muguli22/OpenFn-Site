module OdkToSalesforce
  ##
  # Convert an ODK data hash into a sailiasforce hash from a mapping
  #
  # odk_form -> { sf_object: { sf_field: "value" } }
  class Converter

    def odk_data(salesforce_object, odk_data)
      arr = []
      salesforce_fields = salesforce_object.salesforce_fields.joins(:odk_fields)

      # => Load all the fields that are a repeat
      repeat_odk_fields = salesforce_fields.collect(&:odk_fields).flatten.select{|odk_field| odk_field.repeat_field}.uniq
      non_repeat_odk_fields = salesforce_fields.collect(&:odk_fields).flatten.select{|odk_field| !odk_field.repeat_field}.uniq

      # => Convert the object to an open struct for easier access
      struct = Hashie::Mash.new(odk_data)

      # => Check if the salesforce object is a repeat
      if salesforce_object.is_repeat

        # => Get the first repeat field to extract it's key
        odk_field = repeat_odk_fields.first

        # => Extract the key.  ["repeat_block", "repeat_field"]
        field_nesting = odk_field.field_name.split("/").reject { |f| f.empty? }

        # => Load the repeat object
        repeat = struct.instance_eval(field_nesting[0...-1].join("."))

        repeat = [repeat] unless repeat.is_a?(Array)
        repeat.each do |repeat_hash|
          non_repeat_odk_fields.each do |non_r_field|
            # => Merge the other field values

            key = non_r_field.field_name.split("/").reject { |f| f.empty? }.first
            repeat_hash.merge!(key => struct.send(key))
          end

          arr << repeat_hash
        end
      else
        # => This object is not part of a repeat block
        # => Lets just iterate through the non repeat sections and populate the values
        hsh = {}
        non_repeat_odk_fields.each do |non_r_field|
          # => Merge the other field values
          key = non_r_field.field_name.split("/").reject { |f| f.empty? }.first
          hsh.merge!(key => struct.send(key))
        end

        arr << hsh
      end

      arr
    end

    def get_field_content(odk_field, odk_data)

      # given "/first_level/second_level"
      # -> [ "first_level", "second_level", etc. ]

      struct = Hashie::Mash.new(odk_data)
      key_arr = odk_field.field_name.split("/").reject { |f| f.empty? }

      if odk_field.repeat_field
        value = struct.send(key_arr.last)
      else
        value = struct.instance_eval(key_arr.join("."))
      end

      value = transform_value(value, odk_field.field_type) unless value.is_a?(Array)
      value
    end

    private

    # temporaryly hardcode all staff members as HQ Staff while issue is
    # being sorted out.
    def append_staff_member_type_id(data)
      if data.has_key?(:staff_member__c)
        data[:staff_member__c][:RecordTypeId] = "01290000000hbFGAAY"
      end
      data
    end

    def transform_value(value, data_type)
      # => Transform value from ODK to data_type SF expects
      case data_type
      when "checkbox", "boolean"
        if value.nil? || value.empty? || value.eql?("No")
          value = false
        else
          value = true
        end
      when "double"
        value = value.to_f unless value.nil?
      when "phone"
        value = value.to_s
      end
      value
    end

  end
end
