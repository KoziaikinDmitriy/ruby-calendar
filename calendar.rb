require 'google/apis/calendar_v3'
require './base_cli'

class Calendar < BaseCli
  Calendar = Google::Apis::CalendarV3

  def list()
    calendar = Calendar::CalendarService.new
    calendar.authorization = user_credentials_for(Calendar::AUTH_CALENDAR)

    page_token = nil
    limit = options[:limit] || 1000
    now = Time.now.iso8601

    p 'Enter date in format YYYY-MM-DD'
    inp = gets

    min = DateTime.strptime(inp, '%Y-%m-%d').iso8601

    max = DateTime.strptime(inp + '23:59:59', '%Y-%m-%d %H:%M:%S').iso8601

    begin
      result = calendar.list_events('primary',
                                    max_results: [limit, 100].min,
                                    single_events: true,
                                    order_by: 'startTime',
                                    time_min: min,
                                    time_max: max,
                                    page_token: page_token,
                                    fields: 'items(id, summary, start, attendees),next_page_token')

      result.items.each do |event|
        time = event.start.date_time || event.start.date
        p "#{time.ctime}, #{event.summary}"
        p "Attendees:"
        event.attendees.each do |member|
          p "#{member.email}, #{member.display_name}"
        end
      end
      limit -= result.items.length
      if result.next_page_token
        page_token = result.next_page_token
      else
        page_token = nil
      end
    end while !page_token.nil? && limit > 0
  end
end

calendar = Calendar.new

calendar.list
