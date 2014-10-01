module OdkToSalesforce
  class Dispatcher

    @queue = :importer

    def self.perform(mapping_id, limit = 500)
      mapping = Mapping.find mapping_id
      new.perform(mapping, limit)
    end

    def perform(mapping, limit)
      # Load the log of the import for this ODK form
      import = Import.find_or_create_by(odk_formid: mapping.odk_form.name)

      # => Load the ODK information
      odk = OdkToSalesforce::Odk.new(mapping.odk_form.name, import, limit, mapping.user)

      restforce_connection = RestforceService.new(mapping.user).connection

      # => Get the submissions from the ODK object
      # => The submissions only come back as IDs
      #only = odk.submissions.length if only.nil?
      #submissions = odk.submissions[0...only]
      submissions = odk.submissions

      # => If there are submissions to process
      if submissions.size > 0

        # => Create a converter object from our mapping
        #converter = OdkToSalesforce::Converter.new(mapping)

        # => Load the Salesforce information
        #salesforce = OdkToSalesforce::Salesforce.new(user, mapping)

        # => Create a runner object that will do the processing
        #runner = OdkToSalesforce::Runner.new(salesforce.relationships, user)

        # => Go through each submission to be processed
        submissions.each_with_index do |submission, i|

          # => Get the ODK Data for this submission from the ID
          odk_data = odk.fetch_submission(submission)

          #SalesforceObjects::ImportObject.new(@rf, node: node, attributes: constraints)

          mapping.salesforce_objects.order(:order).each do |salesforce_object|
            salesforce_object.salesforce_fields.joins(:odk_fields).each do |salesforce_field|
              salesforce_field.set_field_content_from_odk_data(odk_data)
              binding.pry
            end
          end

          # => Use the converter to take the mapping and ODK data and create a SF Import Data object
          #sf_data = converter.convert(odk_data)

          #puts sf_data.inspect

          # => Create a list of ImportObjects
          #bottom_objects = []

          # => Go through each branch of the SF object tree
          # salesforce.leaf_nodes.each_with_index do |k, ii|
          #   puts "\n\n-> dispatching submission #{i + 1} of #{submissions.length} on leaf node #{ii + 1} of #{salesforce.leaf_nodes.size} (#{k})".yellow

          #   # => We have the bottom object with all it's parent relationships
          #   # => Add it to the array of bottom objects

          #   # => Remove if statement and run it on all leaf nodes
          #   # => This allows mappings that don't have a bottom object in it, to still traverse the
          #   # => bottom object to try and create any parents it might have.

          #   # => We always start at the bottom of a tree and try to create upwards.  If there
          #   # => are no bottom objects, parents won't be attempted.
          #   bottom_objects << runner.run(k.to_sym, sf_data) # if sf_data.has_key?(k.to_sym)
          # end

          # # => Process all the ImportObjects
          # process_bottom_objects(bottom_objects)

          # import.update(last_uuid: submission, num_imported: import.num_imported + 1)
        end
      end
    end

    # => This function will traverse all the bottom objects and merge them into 1 tree
    # => and return the top most object which will then be created with all it's children
    def process_bottom_objects(bottom_objects)
      other_bottom_objects = []

      # => Loop through all bottom objects
      bottom_objects.each do |bo|
        # => If the bottom object is stand-alone, create it
        if bo.parent.nil?
          bo.save!
        else
          # => This object has parents, put it in an array and process them later
          other_bottom_objects << bo
        end
      end

      # => Combine all bottom objects to get a complete heirarchy
      # => This will give you a bottom object that has a parent
      # => This parent can have a parent
      # => It will have children
      unless other_bottom_objects.empty?
        obj = other_bottom_objects.reduce(:+)

        while obj.parent
          obj = obj.parent
        end

        # => Save the top most object
        obj.save!
      end
    end
  end
end
