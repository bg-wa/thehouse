module KodiHelper
  KODI_URL = 'http://osmc.local:8080/jsonrpc?request='

  private

  def kodi_intent_handler(intent_name)
    alexa_response_text = ''

    case intent_name
      when 'kodiPause'
        kodi_command('Player.PlayPause', {'playerid':1})
      when 'kodiPlay'
        kodi_command('Player.PlayPause', {'playerid':1})
      when 'kodiStop'
        kodi_command('Player.Stop', {'playerid':1})
      when 'kodiSelect'
        kodi_command('Input.Select')
      when 'kodiBack'
        kodi_command('Input.Back')
      when 'kodiUp'
        kodi_command('Input.Up')
      when 'kodiDown'
        kodi_command('Input.Down')
      when 'kodiLeft'
        kodi_command('Input.Left')
      when 'kodiRight'
        kodi_command('Input.Right')
      when 'kodiHome'
        kodi_command('Input.Home')
      when 'kodiMenu'
        kodi_command('Input.ContextMenu')
      when 'kodiReboot'
        kodi_command('System.Reboot')
      when 'kodiShutdown'
        kodi_command('System.Shutdown')
      when 'kodiVolumeUp'
        change_volume('up')
      when 'kodiVolumeDown'
        change_volume('down')
    end

    return alexa_response_text
  end

  def change_volume(direction)
    increment = 10
    if params['request']['intent']['slots']['delta']['value']
      increment = params['request']['intent']['slots']['delta']['value'].to_i * 10
    end

    if direction == 'down'
      increment = increment * -1
    end

    params = {
        'properties': ['volume']
    }
    old_volume = get_volume(params)
    new_volume = old_volume + increment
    new_volume = 100 if new_volume > 100
    new_volume = 0 if new_volume < 0
    params = {
        volume:new_volume
    }
    kodi_command('Aplication.SetVolume', params)
  end

  def get_volume(params)
    response = JSON.parse kodi_command('Application.GetProperties', params).to_json
    return response['result']['volume'].to_i
  end

  def kodi_command(action, params = {})
    request = {
        'jsonrpc': '2.0',
        'method': action,
        'params': params,
        'id':1
    }
    response = HTTParty.get(KODI_URL + request.to_json)
    return response
  end
end