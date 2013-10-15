require 'thread'
 
class ThreadPuddle
  attr_reader :size
 
  def initialize size = 24
    @size  = size
    @queue = Queue.new
    @pool  = size.times.map do
      Thread.new do
        catch :exit do
          loop do
            job, args = queue.deq
            job.call *args
          end
        end
      end
    end
  end
 
  def submit *args, &block
    queue.enq [block, args]
  end
 
  def shutdown timeout = nil
    size.times do
      submit do
        throw :exit
      end
    end
 
    if timeout
      shutdown_with_timeout timeout
    else
      pool.each &:join
    end
 
    queue.clear
    size = 0
  end
 
  def status
    {
      :size    => size,
      :threads => pool.map(&:status), 
      :queue   => {
        :size  => queue.size,
        :consumers => queue.num_waiting,
      },
    }
  end
 
  private
  attr_reader :queue, :pool
 
  def shutdown_with_timeout timeout
    Timeout.timeout timeout.to_i do
      pool.each &:join
    end
  rescue Timeout::Error
    pool.each &:kill
  end
end