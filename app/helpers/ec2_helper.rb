module Ec2Helper

  def start_daemon
    EC2_INSTANCE.start
    EC2_INSTANCE.wait_until_running
  end

  def stop_daemon
    EC2_INSTANCE.stop
    EC2_INSTANCE.wait_until_stopped
  end
end
