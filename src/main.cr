require "./query"
require "logger"
require "./const"
require "socket"

# Clears the terminal, we use this weird string becuase it is portable and is supported on most terminals.
print "\e[1;1H\e[2J"

# The total amount of possible IPv4s.
IPV4_COUNT = 4294967296

cli = TCPSocket.new
cli.connect(ADDR, PORT)

running = 0
success = 0
total = 0
estimate_time_left = Time::Span.new
elapsed_seconds = 0

sleep 1.seconds

spawn do
  while true
    elapsed_seconds += 1
    estimate_time_left = Time::Span.new(seconds: ((IPV4_COUNT - total) / (total / elapsed_seconds)).to_i64)
    sleep 1.seconds
  end
end

include Logger::Utils # cursor_beg(); cursor_up(); clear_line()

spawn do
  while true
    cursor_beg(); cursor_up(); clear_line()
    Logger.infoln "(#{success}/#{total}) #{((total * 100) / IPV4_COUNT).round(2)}% done #{(estimate_time_left.total_hours - (estimate_time_left.minutes / 60)).to_i64}h#{estimate_time_left.minutes}m#{estimate_time_left.seconds}s left (#{(((total / elapsed_seconds) * 22) / 1000).round(2)}kb/s)"
    sleep 100.milliseconds
  end
end

256.times do |x|
  256.times do |y|
    256.times do |z|
      256.times do |w|
        running += 1
        total += 1

        if running >= 15000
          sleep 250.milliseconds
        end
        spawn do
          addr = "#{w}.#{z}.#{y}.#{x}"
          r = Query.query addr, 19132
          if r != nil
            cli.send "#{addr} = #{r.to_json}"
            success += 1
          end
          running -= 1
        end
      end
    end
  end
end
