class HitcountWorker
  include Sidekiq::Worker
  def perform(id)
    puts id
    url = Url.find(id)
    if url.count == nil
      url.update(count: 1)
    else
      current_count = url.count 
      url.update(count: current_count + 1)
    end
  end 
end