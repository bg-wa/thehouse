module RepetierhostHelper
  PRINTER_API_KEY = ENV['REPETIER_HOST_API_KEY']

  private
  @slug

  def repetierhost_intent_handler(intent_name)
    alexa_response_text = ''
    printers = JSON.parse printer_action('list', '', '', {}, PRINTER_API_KEY)
    if printers.nil?
      return 'Cannot connect to printer.'
    else
      @slug = printers['data'][0]['slug']
    end

    case intent_name
      when 'printerStatus'
        # Bed and Extruder Temp
        data = {
            includeHistory: false
        }
        printer_response = JSON.parse printer_action('api', @slug, 'stateList', data, PRINTER_API_KEY)

        printer_response.each do |printer|
          bed_temp = printer[1]['heatedBed']['tempRead'].round(1)
          extruder_temp = printer[1]['extruder'][0]['tempRead'].round(1)
          alexa_response_text += 'Current bed temp is '+bed_temp.to_s+'.  Current extruder temp is '+ extruder_temp.to_s
        end

        #Job % Status
        printer_response = JSON.parse printer_action('api', @slug, 'listJobs', data, PRINTER_API_KEY)

        printer_response['data'].each do |job|
          # TODO: send job %
          temp = job
          alexa_response_text += ''
        end

      when 'printerHome'
        go_home

      when 'printerStop'
        printer_action('api', @slug, 'stopJob', {}, PRINTER_API_KEY)
        go_home
        alexa_response_text += 'print job stopped. sending printer to home position.'

      when 'printerPreheat'
        filament_type = params['request']['intent']['slots']['filamentType']['value']
        case filament_type
          when 'abs'
            bed_temp = 110
            extruder_temp = 225
          when 'pla'
            bed_temp = 60
            extruder_temp = 190
        end

        go_home

        # Set Bed Temp
        set_bed_temp(bed_temp)

        # Set Extruder Temp
        set_extruder_temp(extruder_temp)

        alexa_response_text += 'Printer preheating for '+ filament_type.to_s + 'filament'

      when 'printerBedOn'
        temp = params['request']['intent']['slots']['bedTemp']['value']
        if temp.nil?
          temp = 110
        end
        set_bed_temp(temp)
        alexa_response_text += 'Bed Preheating to '+ temp.to_s

      when 'printerBedOff'
        set_bed_temp(0)
        alexa_response_text += 'Bed off'

      when 'printerExtruderOn'
        temp = params['request']['intent']['slots']['extruderTemp']['value']
        if temp.nil?
          temp = 225
        end
        set_extruder_temp(temp)
        alexa_response_text += 'Extruder Preheating to '+ temp.to_s

      when 'printerExtrude'
        length = params['request']['intent']['slots']['length']['value']
        if length.nil?
          length = 10
        end
        extrude(length)
        alexa_response_text += 'Extruding '+ length.to_s + " millimeters"

      when 'printerExtruderOff'
        set_extruder_temp(0)
        alexa_response_text += 'extruder off'

      when 'printerPreheat'
        temp = params['request']['intent']['slots']['fialmentType']['value']
        if temp.nil?
          temp = 225
        end
        set_extruder_temp(temp)
        alexa_response_text += 'Extruder Preheating to '+ temp.to_s

      when 'printerShutdown'
        printer_action('api', @slug, 'stopJob', {}, PRINTER_API_KEY)

        set_bed_temp(0)

        set_extruder_temp(0)

        go_home

        alexa_response_text += 'printer shutting down'
    end

    return alexa_response_text
  end


  def set_extruder_temp(extruder_temp)
    cmd = 'M104 S' + extruder_temp.to_s + ' T0'
    data = {
        cmd: cmd
    }
    printer_action('api', @slug, 'send', data, PRINTER_API_KEY)
  end

  def extrude(length)
    data = {
        cmd: 'G91'
    }
    printer_action('api', @slug, 'send', data, PRINTER_API_KEY)

    data = {
        cmd: 'G1 E' + length.to_s + ' F120'
    }
    printer_action('api', @slug, 'send', data, PRINTER_API_KEY)

    data = {
        cmd: 'G90'
    }
    printer_action('api', @slug, 'send', data, PRINTER_API_KEY)
  end

  def set_bed_temp(bed_temp)
    cmd = 'M140 S' + bed_temp.to_s
    data = {
        cmd: cmd
    }
    printer_action('api', @slug, 'send', data, PRINTER_API_KEY)
  end

  def go_home
    data = {
        cmd: 'G28'
    }
    printer_action('api', @slug, 'send', data, PRINTER_API_KEY)
    return 'Sending printer to home position.'
  end

  def printer_action(cmd_group, slug, action, data, api_key)
    uri = "http://10.10.0.88:3344/printer/" + cmd_group + "/" + slug + "?a=" + action + "&data=" + data.to_json + "&apikey=" + api_key
    response = HTTParty.get(uri)
    return response
  end
end