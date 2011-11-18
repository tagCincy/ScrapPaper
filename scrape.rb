require 'nokogiri'
require 'httparty'

class Scrape
  include HTTParty

  SKILL_LEVEL_REGEX = /([A-Za-z]+).+\(Lv\.\s\d-(\d)\d\)/

  def self.get_html
    url = "http://lodestone.finalfantasyxiv.com/pl/recipe"
    headers = {"Accept-Language" => "en-US", "User-Agent" => "Mozilla/5.0"}
    data = {"classId" => "A", "rankId" => 1}
    @result = HTTParty.get(url, :headers => headers, :query => data)
  end

  def self.scrape_page
    html = get_html
    doc = Nokogiri::HTML(html)

    skill_level = doc.css("div.recipe-box-class-lv-inner").first.inner_text().strip!

    @skill = skill_level.gsub(SKILL_LEVEL_REGEX) { $1 }
    @tier = skill_level.gsub(SKILL_LEVEL_REGEX) { $2 }

    puts "#{@skill} #{@tier}"

    doc.css("div.recipe-box-body").each do |recipe|
      item_name = recipe.css("td.itemName").inner_text()
      item_quantity = recipe.css("td.recipe-item-box div.recipe-item-badgeC").inner_text()
      item_kind = recipe.css("td.recipe-type-kind").inner_text()

      recipe.css("td.recipe-crystal-box").each do |crystal|

        unless crystal.attribute("style").nil?
          puts "#{crystal.attribute("style")} #{crystal.css("div.recipe-item-badgeC").inner_text()}"
        end

      end

    end

  end
end


Scrape.scrape_page