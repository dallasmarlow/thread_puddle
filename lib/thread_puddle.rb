require 'thread'
 
class ThreadPuddle
  attr_reader :size, :state
 
  def initialize size = 24
    @size  = size
    @state = :running
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
    if state == :running
      queue.enq [block, args]
    else
      raise "thread pool has been shutdown"
    end
  end
 
  def shutdown timeout = nil
    state = :shutting_down

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
    state = :terminated
    size  = 0
  end
 
  def status
    {
      :size    => size,
      :state   => state,
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
