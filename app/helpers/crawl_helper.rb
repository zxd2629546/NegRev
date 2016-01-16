require 'open-uri'
require 'thread'
require 'json'
require 'nokogiri'

module CrawlHelper
  $zol_link_regexp = /href\=\"\/cell_phone\/[^\"]*\"/
  $zol_review_link_regexp = /href\=\"[^\"]*review.shtml\"/

  $jd_link_regexp = /href\=\"\/\/item\.jd\.com\/[^\"]*html\"/
  $jd_review_link_regexp = /href\=\"[^\"]*review.shtml\"/
  $jd_comment_version_regexp = /commentVersion:'\d+'/
  $TAGS = %w(反映慢 耗电 分辨率低 经常死机 无法接打电话 开机慢 性价比低 信号差 配色少 预装软件太多)

  class CrawlZOL
    def initialize depth
      @links = []
      @depth = depth
      @util = ZOLUtil.new
    end
    def get_links page
      p "now is zol page:#{page}"
      begin
        url = "http://detail.zol.com.cn/cell_phone_index/subcate57_0_list_1_0_1_2_0_#{page}.html"
        @html = open(url).read
      rescue
        @html = ''
      end
      @html.scan($zol_link_regexp) do |match|
        @links << match.to_s
      end
    end

    def crawl_reviews target, limit
      puts "crawl reviews"
      target_address = open(@util.from_review_link target.strip).read
      title = Nokogiri::HTML(target_address).css("title").text
      pro_name = title.scan(/【.+】/)[0]
      parts = pro_name[1, pro_name.size - 2].split
      pro_name = parts[0] + parts[1]
      pro_id = Product.where(:name => pro_name).first
      if pro_id.nil? == false
        pro_id = pro_id.id
      else
        return nil, nil
      end

      review_address = target_address.scan($zol_review_link_regexp)[0]
      args = @util.parse_link review_address
      comment_array = []
      1.upto(limit) do |page|
        detail_review_link = @util.form_review_detail_link args[1], page
        detail_page = open(detail_review_link).read
        json = JSON.parse detail_page
        comments = Nokogiri::HTML(json['list'])
        comment_array << comments.css("li.comments-item")
      end
      return comment_array, pro_id
    end

    def crawl
      1.upto(@depth) do |page|
        get_links page
      end
      @links.uniq!
    end
  end

  class CrawlJD
    def initialize depth
      @links = []
      @depth = depth
      @util = JDUtil.new
    end

    def get_links page
      p "now is jd page:#{page}"
      begin
        url = "http://search.jd.com/Search?keyword=%E6%89%8B%E6%9C%BA&enc=utf-8&suggest=1.def.0&wq=shouji&pvid=fpzay7ji.1xa8qq#keyword=%E6%89%8B%E6%9C%BA&enc=utf-8&qrst=1&rt=1&stop=1&vt=2&sttr=1&cid2=653&cid3=655&page=#{page}&click=0"
        @html = open(url).read
      rescue
        @html = ''
      end
      @html.scan($jd_link_regexp) do |match|
        @links << match.to_s
      end
    end

    def crawl_reviews target, limit
      puts "crawl reviews"
      target_address = open(@util.from_review_link target.strip).read
      tmp_str = target_address.scan($jd_comment_version_regexp)[0]
      comment_version = tmp_str[16, tmp_str.size - 17]
      id = @util.parse_link target
      cur_cnt = 0
      comment_array = []
      0.upto(limit) do |page|
        json_addreess = @util.from_comment_json_address id, comment_version, page
        begin
          json = JSON.parse open(json_addreess).read()[/\{.+\}/]
          poor_cnt = json['productCommentSummary']['poorCount']
          comment_array += json['comments']
          cur_cnt += json['comments'].size
        rescue
          cur_cnt += 10086
        end
        if poor_cnt.nil? or cur_cnt >= poor_cnt
          break
        end
      end
      return comment_array
    end

    def parse_product_name target
      html = Nokogiri::HTML open("#{@util.from_main_link target}#product-detail").read
      html.css('div.p-parameter').css('ul')[1].css('li')[0].text.split('：')[1]
    end

    def crawl_img target
      begin
        html = Nokogiri::HTML open(@util.from_main_link target).read
        src = html.css('ul.lh').css('img')[0].attributes['src']
        return "http:#{src}"
      rescue
        "#{href} has error in img"
      end
      return nil
    end

    def crawl_desc target
      html = Nokogiri::HTML open("#{@util.from_main_link target}#product-detail").read
      desc = String.new
      html.css('div.p-parameter').css('ul').css('p').each do |child|
        desc << "\n#{child.text.strip}"
      end
      return desc
    end

    def crawl
      1.upto(@depth) do |page|
        get_links page
      end
      @links.uniq!
    end
  end

  class ZOLUtil

    def parse_review_date content
      content.css("span.date").text
    end

    def parse_review_bad content
      begin
        ret = nil
        html = content.css("div.comments-words")
        html.each do |item|
          if item.css("span.bad") != nil
            ret = item.css("span")[0].text
            break
          end
        end
      rescue => ex
        puts content
      end
      return ret
    end

    def parse_review_user user
      ret = user.css("a").text
      if ret.size == 0
        ret = user.css("span").text
      end
      return ret
    end

    def from_review_link href
      href = href[6, href.size() - 7]
      "http://detail.zol.com.cn#{href}"
    end

    def parse_link href
      items = href.split('/')
      items[1, 2]
    end

    def form_review_detail_link id, page
      if page == 1
        "http://detail.zol.com.cn/xhr3_Review_GetListAndPage_proId=#{id}%5EpageType=Detail%5EisFilter=1%5Eorder=1%5Elevel=5.html"
      else
        "http://detail.zol.com.cn/xhr3_Review_GetListAndPage_pageType=Detail%5Eorder=1%5Elevel=5%5EisFilter=1%5EproId=#{id}%5Epage=#{page}.html"
      end
    end
  end

  class JDUtil
    def from_main_link href
      href = href[6, href.size() - 7]
      "http:#{href}"
    end

    def from_review_link href
      href = href[6, href.size() - 7]
      "http:#{href}#comments"
    end

    def parse_link href
      items = href.split('/')
      items[-1][0, items[-1].size - 6]
    end

    def from_comment_json_address id, version, page
      "http://club.jd.com/productpage/p-#{id}-s-1-t-3-p-#{page}.html?callback=fetchJSON_comment98vv#{version}"
    end
  end

  class Data
    def save_bad_comment name, release_time, content, pro_id

      bad_comment = BadComment.new
      bad_comment.content= content
      bad_comment.release_time= release_time
      bad_comment.name= name
      bad_comment.product_id= pro_id
      if BadComment.where({:name => name, :release_time => release_time}).count == 0
        bad_comment.save!
      end
    end

    def save_product name, img, desc
      product = Product.new
      product.name= name
      product.desc= desc
      product.img= img.gsub /\/n5\//, "/n1/"
      product.tags= $TAGS.shuffle![0, 3].join(' ')
      first = Product.where({:img => img}).first
      if first.nil?
        product.save!
        return product.id
      end
      return first.id
    end

    def crawl_zol pages
      crawl = CrawlZOL.new pages
      links = crawl.crawl
      util = ZOLUtil.new
      links.each do |link|
        comments, pro_id = crawl.crawl_reviews(link, 2)
        if !comments.nil?
          comments.each do |comment|
            comment.each do |item|
              content = item.css("div.comments-list-content")
              user = item.css("div.comments-user")
              save_bad_comment(util.parse_review_user(user), util.parse_review_bad(content), util.parse_review_date(content), pro_id)
            end
          end
        end
      end
    end

    def crawl_jd pages
      crawl = CrawlJD.new pages
      links = crawl.crawl

      links.each do |link|
        begin
          img = crawl.crawl_img link
          puts "1"
          desc = crawl.crawl_desc link
          puts "1"
          pro_name = crawl.parse_product_name link
          puts "1"
          pro_id = save_product pro_name, img, desc
          puts "1"
          comments = crawl.crawl_reviews link, 2
          puts "1"
          comments.each do |comment|
            save_bad_comment comment['nickname'], comment['creationTime'], comment['content'], pro_id
          end
        rescue
          puts "some error happend"
        end
      end
    end
  end
end
