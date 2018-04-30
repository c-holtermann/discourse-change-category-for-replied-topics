# name: Change Category for replied topics
# about: Change Category for replied topics
# version: 1.0
# authors: Christoph Holtermann

module ::ChangeCategoryRepliedTopics
	# The "About the ... category" topic doesn't count.
	def self.get_category_topics(category)
		topics = Topic.where(category_id: category.id)
		about_topic = Topic.where(id: category.topic_id).first
		topics_without_about_topic = topics.where.not(id: about_topic.id)
		return topics_without_about_topic
	end

	def self.find_replied(category_slug_from)
		category_from = Category.find_by(slug: category_slug_from)
	
		topics = self.get_category_topics(category_from)
		topics_replied = topics.where.not(posts_count: 1)

		# don't include old topics, threshold = 3 months
		topics_replied = topics_replied.where("updated_at >= ?", Time.current - 3.month)

		return topics_replied
	end

	def self.move_replied(category_slug_from, category_slug_to)
		category_from = Category.find_by(slug: category_slug_from)
		category_to = Category.find_by(slug: category_slug_to)

		# Move to new category.
		topics_replied = self.find_replied(category_slug_from)
        	topics_replied.update_all(category_id: category_to.id)

		# Update topic counts in from and to category.
        	topic_count_from = self.get_category_topics(category_from).count
        	Category.where(id: category_from.id).update_all(topic_count: topic_count_from)
        	topic_count_to = self.get_category_topics(category_to).count
        	Category.where(id: category_to.id).update_all(topic_count: topic_count_to)
	end

	def self.change_replied_topics!
		ChangeCategoryRepliedTopics.move_replied("jungmedizinerforum-kalender-unbeantwortet", "jungmedizinerforum-kalender")
	end
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
