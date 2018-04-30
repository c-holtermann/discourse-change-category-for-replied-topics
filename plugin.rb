# name: Change Category for replied topics
# about: Change Category for replied topics
# version: 1.0
# authors: Christoph Holtermann

module ::ChangeCategoryRepliedTopics
 
end

after_initialize do
  module ::ChangeCategoryRepliedTopics
    class ChangeCategoryRepliedTopicsJob < ::Jobs::Scheduled
      every 1.day

      def execute(args)
        ChangeCategoryRepliedTopics.change_replied_topics!
      end
    end
  end
end
