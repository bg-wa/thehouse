require 'open-uri'

module PageReaderHelper


  private


  def page_reader_launch_handler
    uri = 'https://digg.com'

    page = Nokogiri::HTML(open(uri))

    for i in 0..page.css('.digg-story__title-link').count-1 do
      response_text = page.css('.digg-story__title-link')[i].text +
                      page.css('.digg-story__kicker')[i].text +
                      page.css('.digg-story__description')[i].text
      @response.add_speech(response_text)
    end
  end

end