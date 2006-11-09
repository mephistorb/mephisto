module Technoweenie # :nodoc:
  module ActsAsAttachment # :nodoc:
    # Methods for DB backed attachments
    module DbFileMethods
      def self.included(base) #:nodoc:
        base.belongs_to  :db_file
        base.before_save :save_to_storage # so the db_file_id can be set
      end

      # Gets the attachment data
      def attachment_data
        @attachment_data ||= db_file.data
      end

      protected          
        # Destroys the file.  Called in the after_destroy callback
        def destroy_file
          db_file.destroy if db_file
        end
        
        # Saves the data to the DbFile model
        def save_to_storage
          if @save_attachment
            (db_file || build_db_file).data = attachment_data
            db_file.save!
            self.db_file_id = db_file.id # needed for my own sanity, k thx
          end
          true
        end
    end
  end
end