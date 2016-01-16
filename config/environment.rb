# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

def start_crawl
  while(true)
    CrawlHelper::Data.new.crawl_jd 1
    puts "finish crawl"
    sleep 24 * 3600
  end
end

#Thread.new {start_crawl}
