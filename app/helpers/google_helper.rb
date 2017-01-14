require 'open-uri'

module GoogleHelper


  private

  def google_intent_handler
    html_data = open('http://web.archive.org/web/20090220003702/http://www.sitepoint.com/').read
    nokogiri_object = Nokogiri::HTML(html_data)
    tagcloud_elements = nokogiri_object.xpath("//ul[@class='tagcloud']/li/a")

    tagcloud_elements.each do |tagcloud_element|
      puts tagcloud_element.text
    end



    uri = 'https://www.google.com/search?q='+URI.encode(params['request']['intent']['slots']['Query']['value'])

    content = ''
    page = Nokogiri::HTML(open(uri).read)

    cards = page.css("div.card-section")

    if cards.count > 0
      content = cards[0].text
    end

    return content
  end


  def google_launch_handler

  end

end