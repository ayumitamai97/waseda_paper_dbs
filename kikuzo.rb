require "capybara"
require "capybara/dsl"
require "capybara/poltergeist"
require "date"
require "pry"
require 'phantomjs'
require 'csv'

Capybara.current_driver = :poltergeist

Capybara.configure do |config|
  config.run_server = false
  config.javascript_driver = :poltergeist
  # config.app_host = "http://database.asahi.com" # 学内
  config.app_host = "http://database.asahi.com.ez.wul.waseda.ac.jp" # 学外
  config.default_max_wait_time = 30
  config.ignore_hidden_elements = false
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {:timeout=>120, :js=>true, :js_errors=>false,
  :phantomjs => Phantomjs.path,
  :phantomjs_options => ['--ssl-protocol=default', '--ignore-ssl-errors=false']})
end

include Capybara::DSL # 警告が出るが動く

page.driver.headers = { "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36" }
page.driver.resize_window(1200, 768)

def login_inside_univ
  visit "/index.shtml"
  all("#contentMain a")[0].trigger("click")
  sleep(5)
end

def login_outside_univ
  visit "http://www.wul.waseda.ac.jp.ez.wul.waseda.ac.jp/DOMEST/db_about/dna/dna.html"
  fill_in "user", :with => ARGV[0]
  fill_in "pass", :with => ARGV[1]
  all("input")[3].trigger("click")
  sleep(5)
  visit find("a.A_button")[:href]
  sleep(5)
  all("#contentMain a")[0].trigger("click")
  sleep(10)
end

def search
  conditions = %w(詳細検索 朝日新聞デジタル アエラ 地域面 大阪 名古屋 西部 北海道)
  within_frame(all("frame")[1]) do
    conditions.each do |condition|
      find("label", text: condition).trigger("click")
    end
    all("label", text: "週刊朝日")[1].trigger("click")
    fill_in("txtWord", with: "訪日&中国人")
    all("#optNotNavi6 select")[0].find("option[value='2015']").select_option
    all("#optNotNavi6 select")[1].find("option[value='01']").select_option
    all("#optNotNavi6 select")[2].find("option[value='01']").select_option
    all("#optNotNavi6 select")[4].find("option[value='2015']").select_option
    all("#optNotNavi6 select")[5].find("option[value='12']").select_option
    all("#optNotNavi6 select")[6].find("option[value='31']").select_option
    all("input.btext")[0].trigger("click")
    sleep(5)
  end
end

def get_search_result
  CSV.open("kikuzo_data.csv", "w") do |csv|
    within_frame(all("frame")[1]) do
      $data = []
      for nth_tr in 0..40
        nth_tr % 2 == 0? even_row = nth_tr / 2 : odd_row = 1 + (nth_tr / 2)
        # odd_rowはheader of trを入れるところ、even_rowはcontent of trを入れるところ
        if nth_tr == 0
          $data << []
          all("th").each { |th| $data[even_row] << th.text }
        elsif nth_tr % 2 == 1 # header of tr
          $data << [] # ifのスコープ外で行を作成すると行数が無駄に増える
          within(all("table.topic-list tr")[nth_tr]) do
            for nth_td in 0..8
              if nth_td == 2
                within(all("td")[nth_td]) do
                  $data[odd_row] << all("nobr")[0].text + all("nobr")[1].text
                end
              else
                $data[odd_row] << all("td")[nth_td].text
              end
            end
          end
        elsif nth_tr % 2 == 0 && nth_tr != 0 # main content of tr
          $data << [] # ifのスコープ外で行を作成すると行数が無駄に増える
          within(all("table.topic-list tr")[nth_tr]) do
            $data[even_row] << find("td span a").text
          end
        end
      end # end of nth_tr
    end # end if within_frame
    csv_data = CSV.generate() do |csv|
      $data.each do |d|
        csv << d
      end
    end
    csv_data.gsub!('"', '') # とりあえず
    csv << [csv_data]
  end
end

login_outside_univ
# login_inside_univ
search
get_search_result