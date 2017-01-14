class ApplicationController < ActionController::Base
  respond_to? :json

  include RepetierhostHelper
  include KodiHelper
  include PageReaderHelper
  include GoogleHelper

  def intent_handler
    if params['session'] && params['request']
      @response = AlexaRubykit::Response.new
      skill_id = params['session']['application']['applicationId']

      case params['request']['type']
        when "LaunchRequest"
          case skill_id
            when ENV['ALEXA_SKILL_ID_1'] #KODI
              @response.add_speech kodi_launch_handler
            when ENV['ALEXA_SKILL_ID_2'] #Repetier_Host
              @response.add_speech repetierhost_launch_handler
            when ENV['ALEXA_SKILL_ID_3'] #Page_Reader
              page_reader_launch_handler
          end
        when "IntentRequest"
          intent_name = params['request']['intent']['name']
          case skill_id
            when ENV['ALEXA_SKILL_ID_1'] #KODI
              @response.add_speech kodi_intent_handler(intent_name)
            when ENV['ALEXA_SKILL_ID_2'] #Repetier_Host
              @response.add_speech repetierhost_intent_handler(intent_name)
            when ENV['ALEXA_SKILL_ID_3'] #Page_Reader
              @response.add_speech page_reader_intent_handler(intent_name)
          end
      end

      @response.build_response
      render :json => @response
    else
      render_404
    end


  end

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end
end
