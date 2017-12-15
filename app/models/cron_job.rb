class CronJob
  def self.kill(job_name, max_second)
    ps_cmd = "`ps -ef | grep \"#{job_name}\"`"
    linux_ps = eval(ps_cmd)
    if linux_ps.include?('jruby')
      linux_ps.split("\n").each do |ps|
        if ps.include?('jruby')
          column = ps.split(' ')
          if column[1].to_i != Process.pid
            etime_cmd = "`ps -p #{column[1]} -o etime=`"
            etime_second = etime_to_sec(eval(etime_cmd))
            if etime_second > max_second
              kill_cmd = "`kill -9 #{column[1]}`"
              eval(kill_cmd)
              return 'job_killed'
            else
              return 'job_still_running'
            end
          end
        end
      end
    else
      return 'job_not_found'
    end
  end

  def self.etime_to_sec(etime)
    buf = etime.split(':')
    if etime.include?('-')
      return 86400
    elsif buf.size == 3
      return (buf[0].to_i * 3600) + (buf[1].to_i * 60) + buf[2].to_i
    else
      return (buf[0].to_i * 60) + buf[1].to_i
    end
  end

end