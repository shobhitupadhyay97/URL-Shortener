class Url < ApplicationRecord
	after_create :start

	include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  index_name([Rails.env,base_class.to_s.pluralize.underscore].join('_'))
	before_save { self.long_url = long_url.downcase }
	VALID_LONG_URL_REGEX = /\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/i
  validates :long_url, presence: true, length: { maximum: 255 }, format: { with: VALID_LONG_URL_REGEX }, 
  					uniqueness: { case_sensitive: false }
  validates :domain,  presence: true, length: { maximum: 25 }
  def start
  	CounterWorker.perform_async
  end
end

