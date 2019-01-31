class Url < ApplicationRecord
  
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  index_name([Rails.env,base_class.to_s.pluralize.underscore].join('_'))
  
  VALID_LONG_URL_REGEX = /\A((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}(:[0-9]{1,5})?(\/.*)?\Z/ix
  validates :long_url, presence: true, length: { maximum: 255 }, format: { with: VALID_LONG_URL_REGEX }
  #uniqueness: { case_sensitive: false }
  validates :domain,  presence: true, length: { maximum: 25 }
  validates :short_url,  presence: true, length: { maximum: 25 }

  before_save { self.long_url = long_url.downcase }
  
  after_create :start
  
  settings index: {
    number_of_shards: 1,
    number_of_replicas: 0,
    analysis: {
      analyzer: {
        pattern: {
          type: 'pattern',
          pattern: "\\s|_|-|\\.",
          lowercase: true
        },
        trigram: {
          tokenizer: 'trigram'
        }
      },
      tokenizer: {
        trigram: {
          type: 'ngram',
          min_gram: 3,
          max_gram: 1000,
          token_chars: ['letter', 'digit']
        }
      }
  } } do
    mapping do
      indexes :short_url, type: 'text', analyzer: 'english' do
        indexes :keyword, analyzer: 'keyword'
        indexes :pattern, analyzer: 'pattern'
        indexes :trigram, analyzer: 'trigram'
      end
      indexes :long_url, type: 'text', analyzer: 'english' do
        indexes :keyword, analyzer: 'keyword'
        indexes :pattern, analyzer: 'pattern'
        indexes :trigram, analyzer: 'trigram'
      end
    end
  end

  def self.custom_search(params)
    field = params[:field]+".trigram"
    query = params[:keyword]
    urls = self.__elasticsearch__.search(
    {
      query: {
        bool: {
          must: [{
            term: {
              "#{field}":"#{query}"
            }
          }]
        }
      }
    }).records
    return urls
  end

  def start
    CounterWorker.perform_async
  end
end

