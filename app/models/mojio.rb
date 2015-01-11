MOJIO_ID = ENV['MOJIO_ID']
MOJIO_KEY = ENV['MOJIO_SECRET_KEY']
MOJIO_API_TOKEN = ENV['MOJIO_API_TOKEN']

class Mojio
  include HTTParty

  base_uri 'http://data.api.hackthedrive.com:80/v1'
	headers 'MojioAPIToken' => '3bfb3c70-5528-4424-80c8-122e14fae04e'

  def initialize(mojio_id)
    @mojio_id = mojio_id
  end

  def events
    event_types = ["IgnitionOn","IgnitionOff","BatteryCharging","SpeedLimitDetected","TowStart","Accident","LowFuel","FenceExited"]
    criteria = "EventType%3D#{event_types.join(',')}"
    event_data = self.class.get("/Vehicles/#{@mojio_id}/Events?limit=100&offset=0&sortBy=Time&desc=false&criteria=#{criteria}")
    parse_events(event_data)
  end

  def parse_events(event_data)
    data = event_data['Data']
    return data.map do |event|
      {
        event_type: format_event(event['EventType']),
        created_at: event['Time'],
        lat: event['Location']['Lat'],
        long: event['Location']['Lng'],
        battery: event['BatteryLevel'],
        fuel: event['FuelLevel'],
        odometer: event['Odometer'],
        temp_inside: event['TemperatureInside'],
        heading: event['Heading'],
        orientation: event['Orientation'],
        elevation: event['Altitude']
      }
    end
  end

  def format_event(event)
    case event
    when 'IgnitionOn'
      return 'carOn'
    when 'IgnitionOff'
      return 'carOff'
    else
      return event
    end
  end

end