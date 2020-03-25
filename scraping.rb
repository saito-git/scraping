require 'nokogiri'
require 'open-uri'
require 'csv'

def get_html(url)
  html = open(url) do |f|
    charset = f.charset
    f.read
  end
end

def parse_html(url)
  html = get_html(URI.escape(url))
  Nokogiri::HTML.parse(html, nil, nil)
end

header = %w[shop_name review_total review_plan review_atomosphere review_cuisine review_performance review_service]
results = [header.join(",")]

1.upto(10) do |n|
  url = "https://www.ozmall.co.jp/restaurant/tokyo/area/shibuya/list/?pageNo=#{n}&Q=1&AR=5&PB=0&PE=0&SM=2&MT=0&OD=review&aa60=review#sp_result"
  doc = parse_html(url)

  doc.css(".ozDinIchiObjInf > .cf > dl > dt > a").each do |a|
    shop_url = 'https://www.ozmall.co.jp/' + a[:href]
    post_doc = parse_html(shop_url)
    shop_name = post_doc.css("h1").text
    shop_name_ruby = post_doc.css("h1 > a > span").text
    shop_name_without_ruby = shop_name.delete(shop_name_ruby)
    review_scores = post_doc.css(".common-frame > div > .review__all--cell > dl > dd > span").map { |e| e.text }
    results << [shop_name_without_ruby, review_scores].join(",")
    sleep(10)
  end
end

File.write("output.csv", results.join("\n"))
